const { CoachingSession, Enterprise } = require('../models');

class SessionService {
  async createSession(sessionData) {
    return await CoachingSession.create(sessionData);
  }

  async getCoachSessions(coachId) {
    return await CoachingSession.findAll({
      where: { coach_id: coachId },
      include: [
        { model: Enterprise, as: 'enterprise', attributes: ['business_name'] }
      ],
      order: [['scheduled_date', 'DESC']]
    });
  }

  async getEnterpriseSessions(enterpriseId) {
    return await CoachingSession.findAll({
      where: { enterprise_id: enterpriseId },
      order: [['scheduled_date', 'DESC']]
    });
  }
}

module.exports = new SessionService();
