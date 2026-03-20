const { Training, TrainingAttendance, Enterprise } = require('../models');

class SmsService {
  async sendTrainingReminders(trainingId) {
    const training = await Training.findByPk(trainingId, {
      include: [{
        model: TrainingAttendance,
        as: 'attendees',
        include: [{ model: Enterprise, as: 'enterprise' }]
      }]
    });

    if (!training) throw new Error('Training not found');

    const results = [];
    for (const attendee of training.attendees) {
      const enterprise = attendee.enterprise;
      if (enterprise && enterprise.phone) {
        const message = `REMINDER: Dear ${enterprise.owner_name}, your workshop "${training.title}" is scheduled for ${new Date(training.date).toLocaleString()} at ${training.location || 'the training center'}. Please arrive 15 mins early.`;
        
        // Mocking the SMS delivery
        console.log(`[CMS MOCK SMS] Sending to ${enterprise.phone}: ${message}`);
        
        results.push({
          enterpriseId: enterprise.id,
          phone: enterprise.phone,
          status: 'sent',
          timestamp: new Date()
        });
      }
    }
    return results;
  }
}

module.exports = new SmsService();
