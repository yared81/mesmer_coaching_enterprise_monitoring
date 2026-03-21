const express = require('express');
const router = express.Router();
const enterpriseController = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All enterprise routes are protected
router.use(protect);

router.post(
  '/', 
  authorize('super_admin', 'admin', 'supervisor'), 
  enterpriseController.register
);

router.get(
  '/', 
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager'),
  enterpriseController.list
);

router.get(
  '/:id', 
  authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager'),
  enterpriseController.getById
);

router.put(
  '/:id',
  authorize('super_admin', 'admin', 'supervisor', 'coach'),
  enterpriseController.update
);

module.exports = router;
