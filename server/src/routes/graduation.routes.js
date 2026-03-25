const express = require('express');
const router = express.Router();
const graduationController = require('../controllers/graduation.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

// Get list of enterprises ready for graduation
router.get('/ready', authorize('super_admin', 'admin', 'program_manager'), graduationController.getReady);

// Only managers/admins can graduate an enterprise after review
router.post('/:id/graduate', authorize('super_admin', 'admin', 'program_manager'), graduationController.graduateEnterprise);

module.exports = router;
