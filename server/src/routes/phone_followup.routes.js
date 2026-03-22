const express = require('express');
const router = express.Router();
const phoneFollowupController = require('../controllers/phone_followup.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

router.use(protect);

router.post('/', authorize('super_admin', 'admin', 'supervisor', 'coach'), phoneFollowupController.createLog);
router.get('/my-logs', authorize('super_admin', 'admin', 'supervisor', 'coach'), phoneFollowupController.getCoachLogs);
router.get('/enterprise/:enterpriseId', authorize('super_admin', 'admin', 'supervisor', 'coach', 'me_officer', 'program_manager', 'enterprise_user'), restrictToOwnEnterprise, phoneFollowupController.getEnterpriseLogs);

module.exports = router;
