const { Enterprise, User, Institution } = require('../models');
const { Op } = require('sequelize');

class EnterpriseService {
  /**
   * Register a new enterprise
   */
  async registerEnterprise(data, coachId, institutionId) {
    const enterprise = await Enterprise.create({
      ...data,
      coach_id: coachId,
      institution_id: institutionId
    });

    return enterprise;
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
}

module.exports = new EnterpriseService();
