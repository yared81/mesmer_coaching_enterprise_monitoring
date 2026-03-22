
const trainingService = require('../services/training.service');
const smsService = require('../services/sms.service');

class TrainingController {
  createTraining = async (req, res, next) => {
    try {
      const training = await trainingService.createTraining({
        ...req.body,
        trainer_id: req.user.userId
      });
      res.status(201).json({ success: true, data: training });
    } catch (error) { next(error); }
  };

  getTrainings = async (req, res, next) => {
    try {
      const enterpriseId = req.user.role === 'enterprise_user' ? req.user.enterprise_id : null;
      const trainings = await trainingService.getTrainings(enterpriseId);
      res.status(200).json({ success: true, data: trainings });
    } catch (error) { next(error); }
  };

  getTrainingById = async (req, res, next) => {
    try {
      const training = await trainingService.getTrainingById(req.params.id);
      res.status(200).json({ success: true, data: training });
    } catch (error) { next(error); }
  };

  addAttendee = async (req, res, next) => {
    try {
      const att = await trainingService.addAttendee(req.params.id, req.body.enterprise_id);
      res.status(201).json({ success: true, data: att });
    } catch (error) { next(error); }
  };

  markAttendance = async (req, res, next) => {
    try {
      const att = await trainingService.markAttendance(req.params.attendanceId, req.body.attended, req.body.feedback_score);
      res.status(200).json({ success: true, data: att });
    } catch (error) { next(error); }
  };

  bulkUpdateAttendance = async (req, res, next) => {
    try {
      await trainingService.bulkUpdateAttendance(req.params.id, req.body.attendances);
      res.status(200).json({ success: true, message: 'Attendance sync complete' });
    } catch (error) { next(error); }
  };

  sendReminders = async (req, res, next) => {
    try {
      const results = await smsService.sendTrainingReminders(req.params.id);
      res.status(200).json({ success: true, count: results.length, data: results });
    } catch (error) { next(error); }
  };
}
module.exports = new TrainingController();
