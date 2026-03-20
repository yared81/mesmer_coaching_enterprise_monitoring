const express = require('express');
const router = express.Router();
const phoneFollowupController = require('../controllers/phone_followup.controller');
const { protect } = require('../middleware/auth.middleware');

router.use(protect);

router.post('/', phoneFollowupController.createLog);
router.get('/my-logs', phoneFollowupController.getCoachLogs);
router.get('/enterprise/:enterpriseId', phoneFollowupController.getEnterpriseLogs);

module.exports = router;
