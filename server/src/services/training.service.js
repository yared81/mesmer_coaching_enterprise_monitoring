
const { Training, TrainingAttendance, Enterprise, User } = require('../models');

class TrainingService {
  async createTraining(data) {
    return await Training.create(data);
  }

  async getTrainings(enterpriseId = null) {
    const query = {
      include: [{ model: User, as: 'trainer', attributes: ['name', 'email'] }],
      order: [['date', 'DESC']]
    };

    if (enterpriseId) {
      query.include.push({
        model: TrainingAttendance,
        as: 'attendees',
        where: { enterprise_id: enterpriseId },
        required: true // Must be an attendee to see it
      });
    }

    return await Training.findAll(query);
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

  async bulkUpdateAttendance(trainingId, attendanceList) {
    for (const item of attendanceList) {
      const { enterprise_id, attended, feedback_score } = item;
      // upsert: update if exists (training_id + enterprise_id), elsewhere create
      const [record] = await TrainingAttendance.findOrCreate({
        where: { training_id: trainingId, enterprise_id: enterprise_id }
      });
      await record.update({ attended, feedback_score });
    }
    return true;
  }
}
module.exports = new TrainingService();
