const express = require('express');
const router = express.Router();
const userManagementController = require('../controllers/user_management.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All routes here require authentication and admin/super_admin role
router.use(protect);
router.use(authorize('super_admin', 'admin', 'program_manager'));

// User Management
router.get('/users', userManagementController.getUsers);
router.post('/users', userManagementController.createUser);
router.put('/users/:id', userManagementController.updateUser);
router.patch('/users/:id/toggle-status', userManagementController.toggleUserStatus);

// Institution Management
router.get('/institutions', userManagementController.getInstitutions);
router.post('/institutions', userManagementController.createInstitution);
router.put('/institutions/:id', userManagementController.updateInstitution);

module.exports = router;
