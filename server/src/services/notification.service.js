const { Notification } = require('../models');

class NotificationService {
  async createNotification({ userId, title, message, type = 'info', institutionId = null }) {
    return await Notification.create({
      user_id: userId,
      title,
      message,
      type,
      institution_id: institutionId
    });
  }

  async getUserNotifications(userId) {
    return await Notification.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      limit: 50
    });
  }

  async markAsRead(notificationId) {
    const notification = await Notification.findByPk(notificationId);
    if (notification) {
      notification.is_read = true;
      await notification.save();
    }
    return notification;
  }

  async markAllAsRead(userId) {
    await Notification.update(
      { is_read: true },
      { where: { user_id: userId, is_read: false } }
    );
  }

  async deleteNotification(notificationId) {
    await Notification.destroy({ where: { id: notificationId } });
  }
}

module.exports = new NotificationService();
