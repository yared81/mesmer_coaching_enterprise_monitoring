const notificationService = require('../services/notification.service');

class NotificationController {
  getNotifications = async (req, res, next) => {
    try {
      const notifications = await notificationService.getUserNotifications(req.user.userId);
      res.status(200).json({
        success: true,
        data: notifications
      });
    } catch (error) {
      next(error);
    }
  };

  markAsRead = async (req, res, next) => {
    try {
      await notificationService.markAsRead(req.params.id);
      res.status(200).json({
        success: true,
        message: 'Notification marked as read'
      });
    } catch (error) {
      next(error);
    }
  };

  markAllAsRead = async (req, res, next) => {
    try {
      await notificationService.markAllAsRead(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'All notifications marked as read'
      });
    } catch (error) {
      next(error);
    }
  };

  deleteNotification = async (req, res, next) => {
    try {
      await notificationService.deleteNotification(req.params.id);
      res.status(200).json({
        success: true,
        message: 'Notification deleted'
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new NotificationController();
