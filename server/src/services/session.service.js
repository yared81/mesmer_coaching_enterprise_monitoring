const { CoachingSession, Enterprise, User } = require('../models');
const notificationService = require('./notification.service');

class SessionService {
  async createSession(sessionData) {
    const session = await CoachingSession.create(sessionData);
    
    // Trigger notification for the coach
    try {
      const enterprise = await Enterprise.findByPk(session.enterprise_id);
      await notificationService.createNotification({
        userId: session.coach_id,
        title: 'New Session Scheduled',
        message: `A new session "${session.title}" has been scheduled for ${enterprise.business_name}.`,
        type: 'info',
        institutionId: enterprise.institution_id
      });

      // Also notify supervisors of the institution
      const supervisors = await User.findAll({ 
        where: { institution_id: enterprise.institution_id, role: 'supervisor' } 
      });
      for (const supervisor of supervisors) {
        await notificationService.createNotification({
          userId: supervisor.id,
          title: 'Session Scheduled',
          message: `Coach scheduled a session "${session.title}" for ${enterprise.business_name}.`,
          type: 'info',
          institutionId: enterprise.institution_id
        });
      }
    } catch (e) {
      console.error('Failed to create session notification:', e);
    }

    return session;
  }

  async getCoachSessions(coachId) {
    // TEMPORARY: return all sessions for demo visibility, not just the logged-in coach's.
    // In future we can re-enable filtering by coach_id to enforce per-coach visibility.
    return await CoachingSession.findAll({
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

  async updateSession(sessionId, coachId, updateData) {
    const session = await CoachingSession.findOne({
      where: { id: sessionId, coach_id: coachId }
    });

    if (!session) {
      throw new Error('Session not found or unauthorized');
    }

    return await session.update(updateData);
  }
}

module.exports = new SessionService();
