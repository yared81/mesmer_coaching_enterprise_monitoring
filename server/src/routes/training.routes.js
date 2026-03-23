
const express = require('express');
const router = express.Router();
const trainingController = require('../controllers/training.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

router.route('/')
  .post(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'), trainingController.createTraining)
  .get(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager', 'enterprise_user'), trainingController.getTrainings);

router.route('/:id')
  .get(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager', 'enterprise_user'), trainingController.getTrainingById)
  .post(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'), trainingController.addAttendee);

router.post('/:id/attendance', authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'), trainingController.bulkUpdateAttendance);
router.post('/:id/remind', authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'), trainingController.sendReminders);

router.route('/attendance/:attendanceId')
  .put(authorize('super_admin', 'admin', 'trainer', 'me_officer', 'program_manager'), trainingController.markAttendance);

module.exports = router;
