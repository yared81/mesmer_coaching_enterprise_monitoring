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

      // MERL Phase 3: QC Random Sampling Algorithm (15% chance)
      if (Math.random() < 0.15) {
        try {
          await QcAudit.create({
            target_type: 'baseline',
            target_id: enterprise.id,
            is_random_sample: true,
            status: 'pending'
          });
        } catch (err) {
          console.error('Failed to create QC Audit sampling for baseline enterprise:', err);
        }
      }

      return enterprise;
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
}

module.exports = new EnterpriseService();
