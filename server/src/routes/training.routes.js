
const express = require('express');
const router = express.Router();
const trainingController = require('../controllers/training.controller');
const { protect } = require('../middleware/auth.middleware');

router.use(protect);

router.route('/')
  .post(trainingController.createTraining)
  .get(trainingController.getTrainings);

router.route('/:id')
  .get(trainingController.getTrainingById)
  .post(trainingController.addAttendee);

router.route('/attendance/:attendanceId')
  .put(trainingController.markAttendance);

module.exports = router;
