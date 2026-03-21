const express = require('express');
const router = express.Router();
const ReportController = require('../controllers/report.controller');
const { protect, restrictTo } = require('../middleware/auth.middleware');

// Apply protection to all report routes
router.use(protect);
router.use(restrictTo('supervisor', 'admin'));

/**
 * @route   GET /api/v1/reports/enterprise/:id/pdf
 * @desc    Export a single enterprise progress report as PDF
 * @access  Supervisor, Admin
 */
router.get('/enterprise/:id/pdf', ReportController.exportEnterprisePDF);

/**
 * @route   GET /api/v1/reports/system/csv
 * @desc    Export a system-wide enterprise health summary as CSV
 * @access  Supervisor, Admin
 */
router.get('/system/csv', ReportController.exportSystemCSV);

module.exports = router;
