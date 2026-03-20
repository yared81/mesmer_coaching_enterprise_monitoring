const { Institution, User, Enterprise, CoachingSession, DiagnosisReport, DiagnosisTemplate, Notification, PhoneFollowupLog, sequelize } = require('../models');
const { Op } = require('sequelize');

class DashboardService {
  /**
   * Get aggregate stats for Admin
   */
  async getAdminStats() {
    const [totalInstitutions, totalCoaches, totalEnterprises, recentEnterprises] = await Promise.all([
      Institution.count(),
      User.count({ where: { role: 'coach' } }),
      Enterprise.count(),
      Enterprise.findAll({
        limit: 5,
        order: [['registered_at', 'DESC']],
        include: [
          { model: User, as: 'coach', attributes: ['name'] },
          { model: Institution, as: 'institution', attributes: ['name'] }
        ]
      })
    ]);

    return {
      stats: {
        totalInstitutions,
        totalCoaches,
        totalEnterprises,
        activePrograms: totalInstitutions // Simplified for now
      },
      recentEnterprises
    };
  }

  /**
   * Get aggregate stats for Supervisor
   */
  async getSupervisorStats(institutionId) {
    const [totalCoaches, totalEnterprises, avgReport, recentActivity] = await Promise.all([
      User.count({ where: { institution_id: institutionId, role: 'coach' } }),
      Enterprise.count({ where: { institution_id: institutionId } }),
      DiagnosisReport.findOne({
        include: [{
          model: DiagnosisTemplate,
          as: 'template',
          where: { institution_id: institutionId },
          attributes: []
        }],
        attributes: [
          [sequelize.fn('AVG', sequelize.col('health_percentage')), 'avgHealth']
        ],
        raw: true
      }),
      Notification.findAll({
        where: { institution_id: institutionId },
        limit: 10,
        order: [['created_at', 'DESC']]
      })
    ]);

    return {
      stats: {
        totalCoaches,
        totalEnterprises,
        avgAssessmentScore: avgReport ? parseFloat(parseFloat(avgReport.avgHealth || 0).toFixed(1)) : 0
      },
      recentActivity
    };
  }

  /**
   * Get aggregate stats for Coach
   */
  async getCoachStats(coachId) {
    const [totalEnterprises, totalSessions, avgReport, recentActivity] = await Promise.all([
      Enterprise.count({ where: { coach_id: coachId } }),
      CoachingSession.count({ where: { coach_id: coachId } }),
      DiagnosisReport.findOne({
        include: [{
          model: CoachingSession,
          as: 'session',
          where: { coach_id: coachId },
          attributes: []
        }],
        attributes: [
          [sequelize.fn('AVG', sequelize.col('health_percentage')), 'avgHealth']
        ],
        raw: true
      }),
      Notification.findAll({
        where: { user_id: coachId },
        limit: 10,
        order: [['created_at', 'DESC']]
      }),
      CoachingSession.findAll({
        where: { coach_id: coachId },
        limit: 5,
        order: [['scheduled_date', 'DESC']],
        include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
      }),
      PhoneFollowupLog.findAll({
        where: { coach_id: coachId },
        limit: 5,
        order: [['date', 'DESC']],
        include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
      })
    ]);

    // Merge sessions and phone logs into interactions
    const interactions = [
      ...recentSessions.map(s => ({
        id: s.id,
        type: 'session',
        title: s.enterprise?.business_name || 'Session',
        description: s.title,
        timestamp: s.scheduled_date,
        status: s.status
      })),
      ...recentPhoneLogs.map(p => ({
        id: p.id,
        type: 'phone_call',
        title: p.enterprise?.business_name || 'Phone Call',
        description: p.purpose,
        timestamp: p.date
      }))
    ].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 10);

    return {
      stats: {
        totalEnterprises,
        totalSessions,
        pendingTasks: 0, 
        avgAssessmentScore: avgReport ? parseFloat(parseFloat(avgReport.avgHealth || 0).toFixed(1)) : 0
      },
      recentActivity,
      recentInteractions: interactions
    };
  }
}

module.exports = new DashboardService();
