const { CoachingSession, Enterprise, User, QcAudit } = require('../models');
const notificationService = require('./notification.service');

class SessionService {
  async createSession(sessionData) {
    const { enterprise_id, session_number, followup_type } = sessionData;

    // 1. Enforce 8-Session Sequence for Coaching types
    if (session_number) {
      if (session_number < 1 || session_number > 8) {
        throw new Error('Session number must be between 1 and 8');
      }

      const lastSession = await CoachingSession.findOne({
        where: { enterprise_id },
        order: [['session_number', 'DESC']]
      });

      const expectedNumber = lastSession ? lastSession.session_number + 1 : 1;
      
      if (session_number !== expectedNumber) {
        throw new Error(`Invalid session sequence. Expected Session #${expectedNumber}, but got #${session_number}`);
      }

      // If there was a previous session, ensure it's completed before starting next
      if (lastSession && lastSession.status !== 'completed') {
        throw new Error(`Cannot schedule Session #${session_number} until Session #${lastSession.session_number} is completed.`);
      }
    }

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

    // MERL Phase 3: QC Random Sampling Algorithm (15% chance)
    if (Math.random() < 0.15) {
      try {
        await QcAudit.create({
          target_type: 'session',
          target_id: session.id,
          is_random_sample: true,
          status: 'pending'
        });
      } catch (err) {
        console.error('Failed to create QC Audit sampling for session:', err);
      }
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

    // MERL Compliance: 48-Hour Data Lock
    const hoursSinceCreation = (Date.now() - new Date(session.created_at || session.createdAt).getTime()) / (1000 * 60 * 60);
    if (hoursSinceCreation > 48) {
      throw new Error('48_HOUR_LOCK: This session is locked from edits because it was created over 48 hours ago.');
    }

    // 2. Enforce Metric Capture for Physical Completion
    if (updateData.status === 'completed' && (updateData.followup_type || session.followup_type) === 'physical') {
      const revenue = updateData.revenue_growth_percent !== undefined ? updateData.revenue_growth_percent : session.revenue_growth_percent;
      const employees = updateData.current_employees !== undefined ? updateData.current_employees : session.current_employees;

      if (!revenue && revenue !== 0) {
        throw new Error('Revenue growth percent is required to complete a physical session');
      }
      if (!employees && employees !== 0) {
        throw new Error('Current employee count is required to complete a physical session');
      }
    }

    return await session.update(updateData);
  }
}

module.exports = new SessionService();
