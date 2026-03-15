const { Institution, User, Enterprise, CoachingSession, DiagnosisReport, DiagnosisTemplate, sequelize } = require('../models');
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
      Enterprise.findAll({
        where: { institution_id: institutionId },
        limit: 5,
        order: [['registered_at', 'DESC']],
        include: [{ model: User, as: 'coach', attributes: ['name'] }]
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
      Enterprise.findAll({
        where: { coach_id: coachId },
        limit: 5,
        order: [['registered_at', 'DESC']],
        include: [{ model: User, as: 'coach', attributes: ['name'] }]
      })
    ]);

    return {
      stats: {
        totalEnterprises,
        totalSessions,
        pendingTasks: 0, 
        avgAssessmentScore: avgReport ? parseFloat(parseFloat(avgReport.avgHealth || 0).toFixed(1)) : 0
      },
      recentActivity
    };
  }
}

module.exports = new DashboardService();
