const express = require('express');
const router = express.Router();
const equipmentController = require('../controllers/equipment.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

router.route('/')
  .get(equipmentController.getAllAssets)
  .post(authorize('admin', 'super_admin', 'supervisor'), equipmentController.addEquipment);

router.get('/enterprise/:enterpriseId', equipmentController.getEnterpriseAssets);

router.put('/:id/status', equipmentController.updateStatus);

module.exports = router;
