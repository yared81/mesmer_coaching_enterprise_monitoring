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

  /**
   * @route GET /api/v1/dashboard/coach/:coachId
   * @desc Supervisor role: get stats for a specific coach
   */
  getSpecificCoachStats = async (req, res, next) => {
    try {
      const stats = await dashboardService.getCoachStats(req.params.coachId);
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };
  /**
   * @route GET /api/v1/dashboard/me
   */
  getMeStats = async (req, res, next) => {
    try {
      const stats = await dashboardService.getMeStats();
      res.status(200).json({
        success: true,
        data: stats
      });
    } catch (error) {
      next(error);
    }
  };
  /**
   * @route GET /api/v1/dashboard/activity-feed
   * Returns the 30 most recent actions across sessions, phone logs, IAP tasks, and new enterprises.
   * Scoped by role: coaches see their own, supervisors/admins see their institution's.
   */
  getActivityFeed = async (req, res, next) => {
    try {
      const feed = await dashboardService.getActivityFeed(req.user);
      res.status(200).json({ success: true, data: feed });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/dashboard/coach-portfolio
   * Returns all enterprises owned by the authenticated coach, with task completion stats.
   */
  getCoachPortfolio = async (req, res, next) => {
    try {
      const portfolio = await dashboardService.getCoachPortfolio(req.user.id);
      res.status(200).json({ success: true, data: portfolio });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new DashboardController();
