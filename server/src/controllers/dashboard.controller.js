const dashboardService = require('../services/dashboard.service');

class DashboardController {
  /**
   * @route GET /api/v1/dashboard/admin
   */
  getAdminStats = async (req, res, next) => {
    try {
      const stats = await dashboardService.getAdminStats();
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/dashboard/supervisor
   */
  getSupervisorStats = async (req, res, next) => {
    try {
      const stats = await dashboardService.getSupervisorStats(req.user.institution_id);
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/dashboard/coach
   */
  getCoachStats = async (req, res, next) => {
    try {
      const stats = await dashboardService.getCoachStats(req.user.id);
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new DashboardController();
