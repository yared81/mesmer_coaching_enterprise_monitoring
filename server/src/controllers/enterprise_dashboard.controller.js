const enterpriseDashboardService = require('../services/enterprise_dashboard.service');

class EnterpriseDashboardController {
  /**
   * @route GET /api/v1/enterprise-dashboard/stats
   */
  getStats = async (req, res, next) => {
    try {
      // req.user.id is the User ID
      const stats = await enterpriseDashboardService.getEnterpriseStats(req.user.id);
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new EnterpriseDashboardController();
