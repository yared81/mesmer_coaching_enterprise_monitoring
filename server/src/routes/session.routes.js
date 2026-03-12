const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/session.controller');
const { protect } = require('../middleware/auth.middleware');

router.use(protect);

router.post('/', sessionController.createSession);
router.get('/my-sessions', sessionController.getCoachSessions);
router.get('/enterprise/:enterpriseId', sessionController.getEnterpriseSessions);

module.exports = router;
