const express = require('express');
const router = express.Router();
const userManagementController = require('../controllers/user_management.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All routes here require authentication
router.use(protect);

// User Management
router.get('/users', authorize('super_admin', 'admin', 'program_manager', 'regional_coordinator'), userManagementController.getUsers);
router.post('/users', authorize('super_admin', 'admin', 'program_manager'), userManagementController.createUser);
router.put('/users/:id', authorize('super_admin', 'admin', 'program_manager'), userManagementController.updateUser);
router.patch('/users/:id/toggle-status', authorize('super_admin', 'admin', 'program_manager'), userManagementController.toggleUserStatus);

// Institution Management
router.get('/institutions', authorize('super_admin', 'admin', 'program_manager', 'regional_coordinator'), userManagementController.getInstitutions);
router.post('/institutions', authorize('super_admin', 'admin', 'program_manager'), userManagementController.createInstitution);
router.put('/institutions/:id', authorize('super_admin', 'admin', 'program_manager'), userManagementController.updateInstitution);

module.exports = router;
