
const { Training, TrainingAttendance, Enterprise, User } = require('../models');

class TrainingService {
  async createTraining(data) {
    return await Training.create(data);
  }

  async getTrainings() {
    return await Training.findAll({
      include: [{ model: User, as: 'trainer', attributes: ['name', 'email'] }],
      order: [['date', 'DESC']]
    });
  }

  async getTrainingById(id) {
    return await Training.findByPk(id, {
      include: [
        { model: User, as: 'trainer', attributes: ['name', 'email'] },
        { 
          model: TrainingAttendance, 
          as: 'attendees',
          include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name', 'owner_name', 'phone'] }]
        }
      ]
    });
  }

  async addAttendee(trainingId, enterpriseId) {
    return await TrainingAttendance.create({ training_id: trainingId, enterprise_id: enterpriseId });
  }

  async markAttendance(attendanceId, attended, feedback_score) {
    const record = await TrainingAttendance.findByPk(attendanceId);
    if (!record) throw new Error('Attendance record not found');
    return await record.update({ attended, feedback_score });
  }
}
module.exports = new TrainingService();
