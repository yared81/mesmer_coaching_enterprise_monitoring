const express = require('express');
const router = express.Router();
const iapController = require('../controllers/iap.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

router.use(protect);

router.post('/', authorize('super_admin', 'admin', 'coach'), iapController.createIap);
router.get('/enterprise/:enterpriseId', authorize('super_admin', 'admin', 'program_manager', 'trainer', 'coach', 'enterprise_user'), restrictToOwnEnterprise, iapController.getIapsByEnterprise);
router.post('/:iapId/tasks', authorize('super_admin', 'admin', 'coach'), iapController.addTask);
router.put('/tasks/:taskId', authorize('super_admin', 'admin', 'coach', 'enterprise_user'), iapController.updateTask);

module.exports = router;
