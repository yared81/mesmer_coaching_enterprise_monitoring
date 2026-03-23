const { Training, User, TrainingAttendance, Enterprise } = require('../models');
const { Op } = require('sequelize');

class TrainingService {
  async getSessions(trainerId) {
    return await Training.findAll({
      where: { trainer_id: trainerId },
      include: [
        { model: User, as: 'trainer', attributes: ['name', 'email'] }
      ],
      order: [['date', 'ASC'], ['start_time', 'ASC']]
    });
  }

  async getSessionById(id) {
    return await Training.findByPk(id, {
      include: [
        { model: User, as: 'trainer', attributes: ['name', 'email'] },
        { 
          model: TrainingAttendance, 
          as: 'attendees',
          include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
        }
      ]
    });
  }

  async createSession(sessionData, trainerId) {
    return await Training.create({
      ...sessionData,
      trainer_id: trainerId
    });
  }

  async updateSession(id, updateData, trainerId) {
    const session = await Training.findOne({
      where: { id, trainer_id: trainerId }
    });
    if (!session) throw new Error('Training session not found or unauthorized');
    return await session.update(updateData);
  }

  async deleteSession(id, trainerId) {
    const session = await Training.findOne({
      where: { id, trainer_id: trainerId }
    });
    if (!session) throw new Error('Training session not found or unauthorized');
    await session.destroy();
  }
}

module.exports = new TrainingService();
