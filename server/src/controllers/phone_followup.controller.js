const phoneFollowupService = require('../services/phone_followup.service');

class PhoneFollowupController {
  async createLog(req, res) {
    try {
      const { enterprise_id, purpose, issue_addressed, advice_given, next_action } = req.body;
      const log = await phoneFollowupService.createLog({
        enterprise_id,
        coach_id: req.user.id,
        purpose,
        issue_addressed,
        advice_given,
        next_action,
        date: new Date()
      });

      res.status(201).json({
        success: true,
        data: log
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  async getCoachLogs(req, res) {
    try {
      const logs = await phoneFollowupService.getCoachLogs(req.user.id);
      res.status(200).json({
        success: true,
        data: logs
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  async getEnterpriseLogs(req, res) {
    try {
      const logs = await phoneFollowupService.getEnterpriseLogs(req.params.enterpriseId);
      res.status(200).json({
        success: true,
        data: logs
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new PhoneFollowupController();
