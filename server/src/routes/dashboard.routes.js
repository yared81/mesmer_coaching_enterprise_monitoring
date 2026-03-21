const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboard.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Admin stats
router.get('/admin', protect, authorize('admin'), dashboardController.getAdminStats);

// Supervisor stats
router.get('/supervisor', protect, authorize('supervisor'), dashboardController.getSupervisorStats);

// Coach stats (Self)
router.get('/coach', protect, authorize('coach'), dashboardController.getCoachStats);

// Supervisor: Get specific coach stats
router.get('/coach/:coachId', protect, authorize('supervisor'), dashboardController.getSpecificCoachStats);

// M&E / Program Manager stats
router.get('/me', protect, authorize('me_officer', 'program_manager'), dashboardController.getMeStats);

module.exports = router;
