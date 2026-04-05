const express = require('express');
const router = express.Router();
const graduationController = require('../controllers/graduation.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

// Get list of enterprises ready for graduation
router.get('/ready', authorize('super_admin', 'admin', 'program_manager', 'comms_officer', 'regional_coordinator'), graduationController.getReady);

router.post('/:id/graduate', authorize('super_admin', 'admin', 'program_manager', 'comms_officer'), graduationController.graduateEnterprise);

module.exports = router;
