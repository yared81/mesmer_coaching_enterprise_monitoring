const sessionService = require('../services/session.service');

class SessionController {
  createSession = async (req, res, next) => {
    try {
      const session = await sessionService.createSession({
        ...req.body,
        coach_id: req.user.id
      });

      res.status(201).json({
        success: true,
        data: session
      });
    } catch (error) {
      next(error);
    }
  };

  getCoachSessions = async (req, res, next) => {
    try {
      const sessions = await sessionService.getCoachSessions(req.user.id);
      res.status(200).json({
        success: true,
        data: sessions
      });
    } catch (error) {
      next(error);
    }
  };

  getEnterpriseSessions = async (req, res, next) => {
    try {
      const sessions = await sessionService.getEnterpriseSessions(req.params.enterpriseId);
      res.status(200).json({
        success: true,
        data: sessions
      });
    } catch (error) {
      next(error);
    }
  };

  updateSession = async (req, res, next) => {
    try {
      const session = await sessionService.updateSession(
        req.params.id,
        req.user.id,
        req.body
      );
      
      res.status(200).json({
        success: true,
        data: session
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new SessionController();
