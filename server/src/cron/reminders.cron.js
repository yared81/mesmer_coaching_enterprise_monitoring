const cron = require('node-cron');
const smsService = require('../services/sms.service');

// Run every day at 8:00 AM to send 24h reminders
const startReminderCron = () => {
  console.log('⏰ Initializing 24h Session Reminder Cron Job...');
  
  cron.schedule('0 8 * * *', async () => {
    try {
      console.log('--- SMS CRON START ---');
      const sentIds = await smsService.sendAutomatedSessionReminders();
      console.log(`--- SMS CRON END: ${sentIds.length} reminders processed ---`);
    } catch (error) {
      console.error('SMS Cron Error:', error);
    }
  });
};

module.exports = { startReminderCron };
