const { Institution } = require('../models');

class InstitutionManagementService {
  /**
   * Get all institutions
   */
  async getInstitutions() {
    return await Institution.findAll({
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
    const { name, region, contact_email } = data;
    return await Institution.create({
      name,
      region,
      contact_email
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

    const { name, region, contact_email } = data;
    if (name) institution.name = name;
    if (region) institution.region = region;
    if (contact_email) institution.contact_email = contact_email;

    await institution.save();
    return institution;
  }
}

module.exports = new InstitutionManagementService();
