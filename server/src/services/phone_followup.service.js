const { PhoneFollowupLog, Enterprise, User } = require('../models');

class PhoneFollowupService {
  async createLog(logData) {
    const log = await PhoneFollowupLog.create(logData);
    return await this.getLogById(log.id);
  }

  async getLogById(id) {
    return await PhoneFollowupLog.findByPk(id, {
      include: [
        { model: Enterprise, as: 'enterprise', attributes: ['business_name'] },
        { model: User, as: 'coach', attributes: ['name'] }
      ]
    });
  }

  async getEnterpriseLogs(enterprise_id) {
    return await PhoneFollowupLog.findAll({
      where: { enterprise_id },
      include: [
        { model: User, as: 'coach', attributes: ['name'] }
      ],
      order: [['date', 'DESC']]
    });
  }

  async getCoachLogs(coach_id) {
    return await PhoneFollowupLog.findAll({
      where: { coach_id },
      include: [
        { model: Enterprise, as: 'enterprise', attributes: ['business_name'] }
      ],
      order: [['date', 'DESC']]
    });
  }
}

module.exports = new PhoneFollowupService();
