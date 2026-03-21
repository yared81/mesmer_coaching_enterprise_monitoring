const { Enterprise, IndividualActionPlan, IapTask, sequelize } = require('../models');
const { Op } = require('sequelize');

class AnalyticsService {
  /**
   * Get distribution and performance metrics by sector
   */
  async getSectorAnalytics() {
    // 1. Get total enterprises per sector
    const sectorDistribution = await Enterprise.findAll({
      attributes: [
        'sector',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['sector'],
      raw: true
    });

    // 2. Get average IAP progress per sector
    // This is more complex since progress is calculated based on tasks
    const enterprisesWithProgress = await Enterprise.findAll({
      attributes: ['id', 'sector'],
      include: [{
        model: IndividualActionPlan,
        as: 'actionPlans',
        include: [{ model: IapTask, as: 'tasks', attributes: ['status'] }]
      }]
    });

    const sectorStats = {};
    enterprisesWithProgress.forEach(ent => {
      const sector = ent.sector || 'Unassigned';
      if (!sectorStats[sector]) {
        sectorStats[sector] = { total: 0, completedTasks: 0, totalTasks: 0 };
      }
      
      sectorStats[sector].total += 1;
      ent.actionPlans?.forEach(iap => {
        sectorStats[sector].totalTasks += iap.tasks.length;
        sectorStats[sector].completedTasks += iap.tasks.filter(t => t.status === 'completed').length;
      });
    });

    return Object.keys(sectorStats).map(key => ({
      sector: key,
      count: sectorStats[key].total,
      avgProgress: sectorStats[key].totalTasks === 0 
        ? 0 
        : Math.round((sectorStats[key].completedTasks / sectorStats[key].totalTasks) * 100)
    }));
  }

  /**
   * Get regional performance metrics
   */
  async getRegionalAnalytics() {
    const regionalStats = await Enterprise.findAll({
      attributes: [
        ['location_name', 'region'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'enterpriseCount'],
        [sequelize.fn('AVG', sequelize.col('baseline_score')), 'avgBaseline']
      ],
      group: ['location_name'],
      raw: true
    });

    return regionalStats.map(r => ({
      region: r.region || 'Remote / Unknown',
      enterpriseCount: parseInt(r.enterpriseCount),
      avgBaseline: parseFloat(parseFloat(r.avgBaseline || 0).toFixed(1))
    }));
  }
}

module.exports = new AnalyticsService();
