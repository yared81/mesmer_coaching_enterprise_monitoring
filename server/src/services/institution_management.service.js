const { Institution } = require('../models');

class InstitutionManagementService {
  /**
   * Get all institutions
   */
  async getInstitutions(params = {}) {
    const where = {};
    if (params.parentId) where.parent_id = params.parentId;
    if (params.isRoot === 'true') where.parent_id = null;

    return await Institution.findAll({
      where,
      order: [['name', 'ASC']]
    });
  }

  /**
   * Get specific institution
   */
  async getInstitutionById(id) {
    return await Institution.findByPk(id);
  }

  /**
   * Create a new institution
   */
  async createInstitution(data) {
    const { name, region, contact_email, parent_id } = data;
    return await Institution.create({
      name,
      region,
      contact_email,
      parent_id
    });
  }

  /**
   * Update institution details
   */
  async updateInstitution(id, data) {
    const institution = await Institution.findByPk(id);
    if (!institution) {
      throw new Error('Institution not found');
    }

    const { name, region, contact_email, parent_id } = data;
    if (name) institution.name = name;
    if (region) institution.region = region;
    if (contact_email) institution.contact_email = contact_email;
    if (parent_id !== undefined) institution.parent_id = parent_id;

    await institution.save();
    return institution;
  }
}

module.exports = new InstitutionManagementService();
