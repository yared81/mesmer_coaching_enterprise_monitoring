const express = require('express');
const router = express.Router();
const enterpriseController = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All enterprise routes are protected
router.use(protect);

router.post(
  '/', 
  authorize('admin', 'institution_admin', 'supervisor'), 
  enterpriseController.register
);

router.get(
  '/', 
  enterpriseController.list
);

router.get(
  '/:id', 
  enterpriseController.getById
);

router.put(
  '/:id',
  authorize('admin', 'institution_admin', 'supervisor'),
  enterpriseController.update
);

module.exports = router;
