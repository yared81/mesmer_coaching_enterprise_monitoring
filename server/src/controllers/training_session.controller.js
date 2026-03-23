const trainingService = require('../services/training_session.service');

const getSessions = async (req, res) => {
  try {
    const sessions = await trainingService.getSessions(req.user.id);
    res.json({ success: true, data: sessions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getSessionById = async (req, res) => {
  try {
    const session = await trainingService.getSessionById(req.params.id);
    if (!session) return res.status(404).json({ success: false, message: 'Session not found' });
    res.json({ success: true, data: session });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const createSession = async (req, res) => {
  try {
    const session = await trainingService.createSession(req.body, req.user.id);
    res.status(201).json({ success: true, data: session });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateSession = async (req, res) => {
  try {
    const session = await trainingService.updateSession(req.params.id, req.body, req.user.id);
    res.json({ success: true, data: session });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const deleteSession = async (req, res) => {
  try {
    await trainingService.deleteSession(req.params.id, req.user.id);
    res.json({ success: true, message: 'Session deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getSessions,
  getSessionById,
  createSession,
  updateSession,
  deleteSession
};
