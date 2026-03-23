
const { Training, TrainingAttendance, Enterprise, User } = require('../models');

class TrainingService {
  async createTraining(data) {
    return await Training.create(data);
  }

  async getTrainings(enterpriseId = null, trainerId = null) {
    const query = {
      include: [{ model: User, as: 'trainer', attributes: ['name', 'email'] }],
      order: [['date', 'DESC'], ['start_time', 'DESC']]
    };

    if (enterpriseId) {
      query.include.push({
        model: TrainingAttendance,
        as: 'attendees',
        where: { enterprise_id: enterpriseId },
        required: true
      });
    }

    if (trainerId) {
      query.where = { trainer_id: trainerId };
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

  async updateTraining(id, data, trainerId) {
    const training = await Training.findOne({ where: { id, trainer_id: trainerId } });
    if (!training) throw new Error('Training not found or unauthorized');
    return await training.update(data);
  }

  async deleteTraining(id, trainerId) {
    const training = await Training.findOne({ where: { id, trainer_id: trainerId } });
    if (!training) throw new Error('Training not found or unauthorized');
    await training.destroy();
  }

  async addAttendee(trainingId, enterpriseId) {
    return await TrainingAttendance.create({ training_id: trainingId, enterprise_id: enterpriseId });
  }

  async getTrainerStats(trainerId) {
    const sessions = await Training.findAll({
      where: { trainer_id: trainerId },
      include: [{ model: TrainingAttendance, as: 'attendees' }]
    });

    let totalAttendees = 0;
    let totalScore = 0;
    let scoreCount = 0;
    
    sessions.forEach(s => {
      totalAttendees += (s.attendees || []).length;
      (s.attendees || []).forEach(a => {
        if (a.feedback_score) {
          totalScore += a.feedback_score;
          scoreCount++;
        }
      });
    });

    return {
      totalSessions: sessions.length,
      totalAttendees,
      averageScore: scoreCount > 0 ? (totalScore / scoreCount).toFixed(1) : 0,
      completionRate: sessions.length > 0 ? ((sessions.filter(s => s.status === 'completed').length / sessions.length) * 100).toFixed(0) : 0
    };
  }

  async getMyAttendance(enterpriseId) {
    return await TrainingAttendance.findAll({
      where: { enterprise_id: enterpriseId },
      include: [
        { 
          model: Training, 
          as: 'training',
          include: [{ model: User, as: 'trainer', attributes: ['name'] }]
        }
      ],
      order: [['created_at', 'DESC']]
    });
  }

  async markAttendance(attendanceId, attended, feedback_score, trainer_insight) {
    const record = await TrainingAttendance.findByPk(attendanceId);
    if (!record) throw new Error('Attendance record not found');
    return await record.update({ attended, feedback_score, trainer_insight });
  }

  async bulkUpdateAttendance(trainingId, attendanceList) {
    for (const item of attendanceList) {
      const { enterprise_id, attended, feedback_score, trainer_insight } = item;
      const [record] = await TrainingAttendance.findOrCreate({
        where: { training_id: trainingId, enterprise_id: enterprise_id }
      });
      await record.update({ attended, feedback_score, trainer_insight });
    }
    return true;
  }
}
module.exports = new TrainingService();
