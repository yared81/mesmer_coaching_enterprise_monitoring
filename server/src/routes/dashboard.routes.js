const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboard.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Admin stats
router.get('/admin', protect, authorize('super_admin', 'admin', 'supervisor', 'program_manager'), dashboardController.getAdminStats);

// Supervisor stats
router.get('/supervisor', protect, authorize('supervisor'), dashboardController.getSupervisorStats);

// Coach stats (Self)
router.get('/coach', protect, authorize('coach'), dashboardController.getCoachStats);

// Supervisor: Get specific coach stats
router.get('/coach/:coachId', protect, authorize('supervisor', 'super_admin', 'admin', 'program_manager'), dashboardController.getSpecificCoachStats);

// M&E / Program Manager stats
router.get('/me', protect, authorize('me_officer', 'program_manager', 'super_admin', 'admin'), dashboardController.getMeStats);

// Live Activity Feed (role-scoped)
router.get('/activity-feed', protect, authorize('coach', 'supervisor', 'super_admin', 'admin', 'me_officer', 'program_manager'), dashboardController.getActivityFeed);

// Coach CRM Portfolio
router.get('/coach-portfolio', protect, authorize('coach'), dashboardController.getCoachPortfolio);

module.exports = router;
