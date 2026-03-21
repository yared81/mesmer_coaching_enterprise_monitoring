const express = require('express');
const router = express.Router();
const equipmentController = require('../controllers/equipment.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

router.route('/')
  .get(authorize('super_admin', 'admin', 'trainer', 'me_officer'), equipmentController.getAllAssets)
  .post(authorize('super_admin', 'admin', 'supervisor', 'trainer'), equipmentController.addEquipment);

router.get('/enterprise/:enterpriseId', authorize('super_admin', 'admin', 'trainer', 'coach', 'me_officer', 'enterprise_user'), equipmentController.getEnterpriseAssets);

router.put('/:id/status', authorize('super_admin', 'admin', 'trainer'), equipmentController.updateStatus);

module.exports = router;
