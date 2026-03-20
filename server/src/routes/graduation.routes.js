const express = require('express');
const router = express.Router();
const graduationController = require('../controllers/graduation.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

// Only managers/admins can graduate an enterprise after review
router.post('/:id/graduate', authorize('program_manager', 'admin'), graduationController.graduateEnterprise);

module.exports = router;
