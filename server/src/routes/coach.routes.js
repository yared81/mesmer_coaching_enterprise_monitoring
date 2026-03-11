const express = require('express');
const { protect, restrictTo } = require('../middleware/auth.middleware');
const coachController = require('../controllers/coach.controller');

const router = express.Router();

// Allow only supervisors to access coach management route
router.use(protect);
router.use(restrictTo('supervisor'));

router.route('/')
  .get(coachController.getCoaches)
  .post(coachController.registerCoach);

router.route('/:id')
  .get(coachController.getCoachDetails);

module.exports = router;
