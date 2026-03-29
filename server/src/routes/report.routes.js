const express = require('express');
const router = express.Router();
const ReportController = require('../controllers/report.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

/**
 * @route   GET /api/v1/reports/enterprise/:id/pdf
 * @desc    Export a single enterprise progress report as PDF
 * @access  Coach, Supervisor, Admin
 */
router.get(
  '/enterprise/:id/pdf',
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'program_manager', 'regional_coordinator'),
  ReportController.exportEnterprisePDF
);

/**
 * @route   GET /api/v1/reports/system/csv
 * @desc    Export a system-wide enterprise health summary as CSV
 * @access  Supervisor, Admin
 */
router.get(
  '/system/csv',
  authorize('super_admin', 'admin', 'supervisor', 'program_manager', 'regional_coordinator', 'me_officer'),
  ReportController.exportSystemCSV
);

/**
 * @route   GET /api/v1/reports/weekly
 * @desc    Export a weekly activity summary PDF for the requesting coach
 * @access  Coach, Supervisor
 */
router.get(
  '/weekly',
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'program_manager'),
  ReportController.exportWeeklyReport
);

module.exports = router;
