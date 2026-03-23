const { AuditLog, User } = require('../models');

class AuditController {
  /**
   * @route GET /api/v1/audits
   * @desc Get system audit logs
   */
  getAuditLogs = async (req, res, next) => {
    try {
      const { limit = 50, offset = 0 } = req.query;
      
      const logs = await AuditLog.findAll({
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['timestamp', 'DESC']],
        include: [{
          model: User,
          attributes: ['id', 'name', 'email', 'role'] // Ensure 'User' relation is properly defined in models
        }]
      });

      res.status(200).json({
        success: true,
        data: logs
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new AuditController();
