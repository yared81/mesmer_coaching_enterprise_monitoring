const cron = require('node-cron');
const { Enterprise, CoachingSession, PhoneFollowupLog } = require('../models');
const { Op } = require('sequelize');

// Run every night at midnight
const startStalledEnterpriseJob = () => {
  cron.schedule('0 0 * * *', async () => {
    console.log('[CRON] Running Nightly Stalled Enterprise Scan...');
    try {
      // 30 days ago
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - 30);

      // Find all active enterprises
      const activeEnterprises = await Enterprise.findAll({
        where: { status: { [Op.notIn]: ['graduated', 'dropped', 'stalled'] } }
      });

      let stalledCount = 0;

      for (const enterprise of activeEnterprises) {
        // Check Last Coaching Session
        const lastSession = await CoachingSession.findOne({
          where: { enterprise_id: enterprise.id },
          order: [['scheduled_date', 'DESC']]
        });

        // Check Last Phone Log
        const lastPhoneLog = await PhoneFollowupLog.findOne({
          where: { enterprise_id: enterprise.id },
          order: [['date', 'DESC']]
        });

        const sessionDate = lastSession ? new Date(lastSession.scheduled_date) : null;
        const phoneDate = lastPhoneLog ? new Date(lastPhoneLog.date) : null;
        const regDate = new Date(enterprise.registered_at || enterprise.createdAt);

        // Calculate latest activity
        let latestActivity = regDate;
        if (sessionDate && sessionDate > latestActivity) latestActivity = sessionDate;
        if (phoneDate && phoneDate > latestActivity) latestActivity = phoneDate;

        // If latest activity is older than 30 days, mark as stalled
        if (latestActivity < cutoffDate) {
          await enterprise.update({ status: 'stalled' });
          stalledCount++;
          console.log(`[CRON] Enterprise ${enterprise.business_name} marked as STALLED.`);
        }
      }

      console.log(`[CRON] Scan complete. ${stalledCount} enterprises were marked as stalled.`);
    } catch (error) {
      console.error('[CRON] Error during Stalled Enterprise Scan:', error);
    }
  });
};

module.exports = { startStalledEnterpriseJob };
