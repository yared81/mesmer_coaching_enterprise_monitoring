const express = require('express');
const router = express.Router();
const enterpriseController = require('../controllers/enterprise.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

// All enterprise routes are protected
router.use(protect);

router.post(
  '/', 
  authorize('super_admin', 'admin', 'supervisor', 'program_manager'), 
  enterpriseController.register
);

router.post(
  '/bulk',
  authorize('super_admin', 'admin', 'supervisor', 'program_manager'),
  enterpriseController.bulkRegister
);

router.get(
  '/', 
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager', 'regional_coordinator'),
  enterpriseController.list
);

router.get(
  '/:id', 
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager', 'regional_coordinator', 'enterprise_user'),
  restrictToOwnEnterprise,
  enterpriseController.getById
);

router.put(
  '/:id',
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'enterprise_user', 'program_manager', 'regional_coordinator'),
  restrictToOwnEnterprise,
  enterpriseController.update
);

router.get(
  '/:id/trends',
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager', 'regional_coordinator', 'enterprise_user'),
  restrictToOwnEnterprise,
  enterpriseController.getTrends
);

module.exports = router;
