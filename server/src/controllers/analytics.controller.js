const AnalyticsService = require('../services/analytics.service');

/**
 * Controller for sophisticated platform analytics
 */
exports.getSectorStats = async (req, res, next) => {
  try {
    const data = await AnalyticsService.getSectorAnalytics();
    res.status(200).json({
      success: true,
      data
    });
  } catch (err) {
    next(err);
  }
};

exports.getRegionalStats = async (req, res, next) => {
  try {
    const data = await AnalyticsService.getRegionalAnalytics();
    res.status(200).json({
      success: true,
      data
    });
  } catch (err) {
    next(err);
  }
};

exports.getSystemWideStats = async (req, res, next) => {
  try {
    const data = await AnalyticsService.getSystemWideStats();
    res.status(200).json({
      success: true,
      data
    });
  } catch (err) {
    next(err);
  }
};
