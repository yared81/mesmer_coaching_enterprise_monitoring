const express = require('express');
const router = express.Router();
const enterpriseDashboardController = require('../controllers/enterprise_dashboard.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Enterprise only dashboard stats
router.get('/stats', protect, authorize('enterprise_user'), enterpriseDashboardController.getStats);

module.exports = router;
