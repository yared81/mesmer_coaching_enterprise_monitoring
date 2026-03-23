const express = require('express');
const router = express.Router();
const auditController = require('../controllers/audit.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All audit routes require authentication
router.use(protect);

// Only program manager, admin, super_admin can view audit logs
router.get('/', authorize('super_admin', 'admin', 'program_manager'), auditController.getAuditLogs);

module.exports = router;
