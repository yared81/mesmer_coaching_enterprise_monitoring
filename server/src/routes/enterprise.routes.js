const express = require('express');
const router = express.Router();
const enterpriseController = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All enterprise routes are protected
router.use(protect);

router.post(
  '/', 
  authorize('admin', 'institution_admin', 'coach'), 
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

module.exports = router;
