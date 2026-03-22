const express = require('express');
const router = express.Router();
const AnalyticsController = require('../controllers/analytics.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Apply protection to all analytics routes
router.use(protect);
router.use(authorize('supervisor', 'admin'));

/**
 * @route   GET /api/v1/analytics/sectors
 * @desc    Get distribution and performance data by business sector
 */
router.get('/sectors', AnalyticsController.getSectorStats);

/**
 * @route   GET /api/v1/analytics/regions
 * @desc    Get performance metrics grouped by geographic region
 */
router.get('/regions', AnalyticsController.getRegionalStats);

module.exports = router;
