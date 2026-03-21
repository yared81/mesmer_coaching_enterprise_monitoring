const cron = require('node-cron');
const { IndividualActionPlan, IapTask, Notification, User } = require('../models');
const { Op } = require('sequelize');

/**
 * Nightly job that scans all pending IAP tasks.
 * - Marks tasks as overdue (by creating a notification) if their deadline has passed.
 * - Auto-completes an IAP when ALL its tasks are completed.
 */
const startIapAutomationJob = () => {
  // Run every night at 01:00 AM
  cron.schedule('0 1 * * *', async () => {
    console.log('[CRON] Running Nightly IAP Task Automation Scan...');
    try {
      const now = new Date();

      // ---- 1. Find overdue pending tasks ----
      const overdueTasks = await IapTask.findAll({
        where: {
          status: 'pending',
          deadline: { [Op.lt]: now }
        },
        include: [{
          model: IndividualActionPlan,
          as: 'plan',
          attributes: ['id', 'coach_id', 'enterprise_id']
        }]
      });

      let overdueCount = 0;
      for (const task of overdueTasks) {
        // Notify the assigned coach
        if (task.plan?.coach_id) {
          await Notification.create({
            user_id: task.plan.coach_id,
            type: 'iap_overdue',
            title: 'Overdue IAP Task',
            message: `Task "${task.description.substring(0, 60)}..." is overdue since ${task.deadline.toDateString()}.`,
            is_read: false
          });
          overdueCount++;
        }
      }

      // ---- 2. Auto-complete IAPs where all tasks are done ----
      const activeIaps = await IndividualActionPlan.findAll({
        where: { status: 'active' },
        include: [{ model: IapTask, as: 'tasks', attributes: ['status'] }]
      });

      let completedCount = 0;
      for (const iap of activeIaps) {
        if (iap.tasks.length > 0 && iap.tasks.every(t => t.status === 'completed')) {
          await iap.update({ status: 'completed', signoff_date: now });
          completedCount++;
          console.log(`[CRON] IAP ${iap.id} auto-completed (all tasks done).`);
        }
      }

      console.log(`[CRON] IAP Scan done. Overdue alerts: ${overdueCount}, IAPs auto-completed: ${completedCount}.`);
    } catch (error) {
      console.error('[CRON] IAP Automation Error:', error);
    }
  });
};

module.exports = { startIapAutomationJob };
