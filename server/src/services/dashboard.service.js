const { Institution, User, Enterprise } = require('../models');
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
    const [totalCoaches, totalEnterprises, recentActivity] = await Promise.all([
      User.count({ where: { institution_id: institutionId, role: 'coach' } }),
      Enterprise.count({ where: { institution_id: institutionId } }),
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
        avgAssessmentScore: 0 // TODO: Implement when Phase 4 is done
      },
      recentActivity
    };
  }
}

module.exports = new DashboardService();
