const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboard.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Admin stats
router.get('/admin', protect, authorize('admin'), dashboardController.getAdminStats);

// Supervisor stats
router.get('/supervisor', protect, authorize('supervisor'), dashboardController.getSupervisorStats);

module.exports = router;
