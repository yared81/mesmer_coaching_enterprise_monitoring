const { Enterprise, User, Institution, sequelize } = require('../models');
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
}

module.exports = new EnterpriseService();
