
const trainingService = require('../services/training.service');

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
      const trainings = await trainingService.getTrainings();
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
}
module.exports = new TrainingController();
