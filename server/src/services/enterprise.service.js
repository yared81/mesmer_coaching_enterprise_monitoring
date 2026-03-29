const { Enterprise, User, Institution, QcAudit, CoachingSession, sequelize } = require('../models');
const crypto = require('crypto');
const { Op } = require('sequelize');

class EnterpriseService {
  /**
   * Register a new enterprise and create a corresponding user account
   */
  async registerEnterprise(data, coachId, institutionId) {
    const transaction = await sequelize.transaction();
    try {
      // 1. Create the User account for the enterprise owner
      const defaultPassword = '123456';
      const hashedPassword = await User.hashPassword(defaultPassword);

      const user = await User.create({
        email: data.email,
        name: data.owner_name,
        password_hash: hashedPassword,
        role: 'enterprise',
        institution_id: institutionId,
        is_active: true
      }, { transaction });

      // 2. Create the Enterprise and link to the user
      const enterprise = await Enterprise.create({
        ...data,
        coach_id: coachId,
        institution_id: institutionId,
        user_id: user.id
      }, { transaction });

      await transaction.commit();

      // Centralized QC Trigger Engine (Random Sampling + Risk Flags)
      const qcTriggerService = require('./qc_trigger.service');
      await qcTriggerService.processBaseline(enterprise);

      return enterprise;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Bulk register enterprises and create corresponding user accounts
   */
  async bulkRegisterEnterprises(enterprisesData, coachId, institutionId) {
    const transaction = await sequelize.transaction();
    const createdEnterprises = [];
    const { AuditLog } = require('../models');

    try {
      const defaultPassword = '123456';
      const hashedPassword = await User.hashPassword(defaultPassword);

      for (const data of enterprisesData) {
        // 1. Create the User account
        const user = await User.create({
          email: data.email,
          name: data.owner_name,
          password_hash: hashedPassword,
          role: 'enterprise_user',
          institution_id: institutionId,
          is_active: true
        }, { transaction });

        // 2. Create the Enterprise
        const enterprise = await Enterprise.create({
          ...data,
          coach_id: coachId,
          institution_id: institutionId,
          user_id: user.id
        }, { transaction });

        createdEnterprises.push(enterprise);
      }

      // 3. Batch Audit Logging
      await AuditLog.create({
        user_id: coachId,
        action: 'CREATE',
        table_name: 'enterprises',
        record_id: createdEnterprises[0]?.id || '00000000-0000-0000-0000-000000000000',
        new_data: { bulk: true, count: createdEnterprises.length, ids: createdEnterprises.map(e => e.id) }
      }, { transaction });

      await transaction.commit();

      // 4. Trigger QC Baseline (Post-transaction)
      const qcTriggerService = require('./qc_trigger.service');
      for (const ent of createdEnterprises) {
        await qcTriggerService.processBaseline(ent).catch(err => 
          console.error(`Failed to trigger QC for ${ent.id}:`, err)
        );
      }

      return createdEnterprises;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Count the total number of enterprises for pilot mode capability
   */
  async countEnterprises() {
    return await Enterprise.count();
  }

  /**
   * Get list of enterprises with filters and search
   */
  async getEnterprises(filters = {}) {
    const { 
      search, 
      sector, 
      institution_id, 
      coach_id, 
      user_id,
      page = 1, 
      limit = 10 
    } = filters;

    const query = {
      where: {},
      include: [
        { model: User, as: 'coach', attributes: ['id', 'name', 'email'] },
        { model: Institution, as: 'institution', attributes: ['id', 'name'] }
      ],
      order: [['registered_at', 'DESC']],
      offset: (page - 1) * limit,
      limit: parseInt(limit)
    };

    if (search) {
      query.where[Op.or] = [
        { business_name: { [Op.iLike]: `%${search}%` } },
        { owner_name: { [Op.iLike]: `%${search}%` } }
      ];
    }

    if (sector) {
      query.where.sector = sector;
    }

    if (institution_id) {
      query.where.institution_id = institution_id;
    }

    if (coach_id) {
      query.where.coach_id = coach_id;
    }
    
    if (user_id) {
      query.where.user_id = user_id;
    }

    if (filters.location_name) {
      query.where.location_name = filters.location_name;
    }

    if (filters.status) {
      query.where.status = filters.status;
    }

    const { count, rows } = await Enterprise.findAndCountAll(query);

    return {
      enterprises: rows,
      total: count,
      page: parseInt(page),
      totalPages: Math.ceil(count / limit)
    };
  }

  /**
   * Get single enterprise detail
   */
  async getEnterpriseById(id) {
    const enterprise = await Enterprise.findByPk(id, {
      include: [
        { model: User, as: 'coach', attributes: ['id', 'name', 'email'] },
        { model: Institution, as: 'institution', attributes: ['id', 'name'] }
      ]
    });

    if (!enterprise) {
      throw new Error('Enterprise not found');
    }

    return enterprise;
  }

  /**
   * Update an enterprise
   */
  async updateEnterprise(id, data, userId = null) {
    const enterprise = await Enterprise.findByPk(id);
    if (!enterprise) {
      throw new Error('Enterprise not found');
    }

    // MERL Compliance: 48-Hour Data Lock for Baseline Data
    const hoursSinceCreation = (Date.now() - new Date(enterprise.registered_at || enterprise.createdAt).getTime()) / (1000 * 60 * 60);
    if (hoursSinceCreation > 48) {
      throw new Error('48_HOUR_LOCK: Enterprise baseline data is locked from edits because it was created over 48 hours ago.');
    }

    await enterprise.update(data, { userId });
    return this.getEnterpriseById(id);
  }
  /**
   * Triangulate and Graduate an enterprise
   */
  async graduateEnterprise(id, approverId) {
    const enterprise = await Enterprise.findByPk(id);
    if (!enterprise) throw new Error('Enterprise not found');

    if (enterprise.status === 'graduated') {
      throw new Error('Enterprise is already graduated');
    }

    // Triangulation Check 1: Must have 8 completed sessions
    const sessions = await CoachingSession.findAll({ where: { enterprise_id: id, status: 'completed' }});
    if (sessions.length < 8) {
      throw new Error(`Triangulation Failed: Enterprise only has ${sessions.length}/8 completed sessions.`);
    }

    // Triangulation Check 2: Outstanding QC Audits cannot exist
    const pendingAudits = await QcAudit.count({
      where: { target_id: [id, ...sessions.map(s => s.id)], status: 'pending' }
    });
    if (pendingAudits > 0) {
      throw new Error('Triangulation Failed: There are pending QC Verification checks for this enterprise.');
    }

    // Generate Verification Code (e.g., MES-2026-X8F9)
    const randomHex = crypto.randomBytes(2).toString('hex').toUpperCase();
    const verificationCode = `MES-${new Date().getFullYear()}-${randomHex}`;

    // Update Status
    await enterprise.update({
      status: 'graduated',
      // Store the certificate/verification data inside note or a future dedicated column
    });

    return {
      message: 'Graduation Triangulation Passed successfully.',
      enterpriseId: enterprise.id,
      verificationCode: verificationCode,
      approvedBy: approverId
    };
  }

  /**
   * Get list of enterprises ready for graduation (Triangulated)
   */
  async getGraduationReady(institutionId = null) {
    const enterprises = await Enterprise.findAll({
      where: institutionId ? { institution_id: institutionId, status: { [Op.ne]: 'graduated' } } : { status: { [Op.ne]: 'graduated' } },
      include: [{ model: User, as: 'coach', attributes: ['name'] }],
      attributes: {
        include: [[
          sequelize.literal(`(SELECT COUNT(*) FROM "CoachingSessions" WHERE enterprise_id = "Enterprise".id AND status = 'completed')`),
          'completedCount'
        ]]
      }
    });

    const ready = [];
    for (const ent of enterprises) {
      const count = parseInt(ent.getDataValue('completedCount') || 0);
      if (count >= 1) { // Leniency for hackathon demo: 1+ session instead of 8
        const pendingQC = await QcAudit.count({ where: { target_id: ent.id, status: 'pending' } });
        if (pendingQC === 0) ready.push(ent);
      }
    }
    return ready;
  }

  /**
   * Get historical growth trends (Baseline vs Sessions) for an enterprise
   */
  async getGrowthTrends(enterpriseId) {
    const enterprise = await Enterprise.findByPk(enterpriseId);
    if (!enterprise) throw new Error('Enterprise not found');

    const sessions = await CoachingSession.findAll({
      where: { 
        enterprise_id: enterpriseId,
        status: 'completed'
      },
      order: [['session_number', 'ASC']]
    });

    // Start with Baseline
    const trends = [
      {
        period: 'Baseline',
        revenue: enterprise.annual_revenue || 0,
        employees: enterprise.employee_count || 0,
        date: enterprise.createdAt
      }
    ];

    // Append Sessions
    sessions.forEach(session => {
      trends.push({
        period: `S${session.session_number}`,
        revenue: session.revenue_growth_percent || 0, // In reality, we might calculate absolute if needed, but for now we follow the model
        employees: session.current_employees || 0,
        date: session.updatedAt
      });
    });

    return trends;
  }
}

module.exports = new EnterpriseService();
