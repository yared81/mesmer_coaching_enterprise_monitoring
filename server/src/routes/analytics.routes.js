const express = require('express');
const router = express.Router();
const AnalyticsController = require('../controllers/analytics.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Apply protection to all analytics routes
router.use(protect);
// Apply protection to all analytics routes
router.use(protect);
router.use(authorize('supervisor', 'admin', 'me_officer', 'program_manager', 'regional_coordinator'));

/**
 * @route   GET /api/v1/analytics/system
 * @desc    Get system-wide impact KPIs
 */
router.get('/system', AnalyticsController.getSystemWideStats);

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
