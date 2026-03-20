const { Equipment, Enterprise, User } = require('../models');

class EquipmentService {
  async addEquipment(data) {
    return await Equipment.create(data);
  }

  async getEnterpriseAssets(enterpriseId) {
    return await Equipment.findAll({
      where: { enterprise_id: enterpriseId },
      order: [['received_date', 'DESC']]
    });
  }

  async updateEquipmentStatus(equipmentId, status, notes) {
    const asset = await Equipment.findByPk(equipmentId);
    if (!asset) throw new Error('Asset not found');
    return await asset.update({ status, notes });
  }

  async getAllEquipment() {
    return await Equipment.findAll({
      include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
    });
  }
}

module.exports = new EquipmentService();
