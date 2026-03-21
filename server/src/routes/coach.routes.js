const express = require('express');
const { protect, authorize } = require('../middleware/auth.middleware');
const coachController = require('../controllers/coach.controller');

const router = express.Router();

// Allow only supervisors to access coach management route
router.use(protect);
router.use(authorize('super_admin', 'admin', 'supervisor'));

router.route('/')
  .get(coachController.getCoaches)
  .post(coachController.registerCoach);

router.route('/:id')
  .get(coachController.getCoachDetails);

module.exports = router;
