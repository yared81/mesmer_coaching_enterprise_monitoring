const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/session.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

router.use(protect);

router.post('/', sessionController.createSession);
router.get('/my-sessions', sessionController.getCoachSessions);
router.get('/enterprise/:enterpriseId', authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager', 'enterprise_user'), restrictToOwnEnterprise, sessionController.getEnterpriseSessions);
router.put('/:id', sessionController.updateSession);

module.exports = router;
