
const express = require('express');
const router = express.Router();
const trainingController = require('../controllers/training.controller');
const { protect } = require('../middleware/auth.middleware');

router.use(protect);
router.use(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'));

router.route('/')
  .post(trainingController.createTraining)
  .get(trainingController.getTrainings);

router.route('/:id')
  .get(trainingController.getTrainingById)
  .post(trainingController.addAttendee);

router.post('/:id/attendance', trainingController.bulkUpdateAttendance);
router.post('/:id/remind', trainingController.sendReminders);

router.route('/attendance/:attendanceId')
  .put(trainingController.markAttendance);

module.exports = router;
