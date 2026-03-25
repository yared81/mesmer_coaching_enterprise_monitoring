const { Training, TrainingAttendance, Enterprise, CoachingSession, User } = require('../models');
const { Op } = require('sequelize');

class SmsService {
  /**
   * Internal helper to simulate real-world SMS delivery
   */
  async _sendSMS(phone, message) {
    if (!phone) return false;
    // In production, this would call EthioTelecom or Twilio API
    console.log(`[MESMER SMS GATEWAY] To: ${phone} | Msg: ${message}`);
    return true;
  }

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
        const message = `REMINDER: Dear ${enterprise.owner_name}, your workshop "${training.title}" is tomorrow at ${training.location}. Please be on time.`;
        const success = await this._sendSMS(enterprise.phone, message);
        
        results.push({
          enterpriseId: enterprise.id,
          phone: enterprise.phone,
          status: success ? 'sent' : 'failed',
          timestamp: new Date()
        });
      }
    }
    return results;
  }

  /**
   * Automated 24h Reminders for Coaching Sessions
   */
  async sendAutomatedSessionReminders() {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Find sessions scheduled for tomorrow that haven't been completed
    const sessions = await CoachingSession.findAll({
      where: {
        scheduled_date: {
          [Op.between]: [
            new Date(tomorrow.setHours(0,0,0,0)),
            new Date(tomorrow.setHours(23,59,59,999))
          ]
        },
        status: 'scheduled'
      },
      include: [
        { model: Enterprise, as: 'enterprise' },
        { model: User, as: 'coach', attributes: ['name', 'phone'] }
      ]
    });

    console.log(`[SMS CRON] Found ${sessions.length} sessions for 24h reminders`);

    const results = [];
    for (const session of sessions) {
      // 1. Alert Enterprise
      if (session.enterprise?.phone) {
        const msg = `MESMER ALERT: Dear ${session.enterprise.owner_name}, you have a coaching visit scheduled for tomorrow. Please ensure your records are ready.`;
        await this._sendSMS(session.enterprise.phone, msg);
      }

      // 2. Alert Coach
      if (session.coach?.phone) {
        const msg = `MESMER COACH: Reminder for session "${session.title}" with ${session.enterprise.business_name} tomorrow. GPS capture is required.`;
        await this._sendSMS(session.coach.phone, msg);
      }
      
      results.push(session.id);
    }
    return results;
  }
}

module.exports = new SmsService();
