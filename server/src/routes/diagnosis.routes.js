const express = require('express');
const router = express.Router();
const diagnosisController = require('../controllers/diagnosis.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// All diagnosis routes require authentication
router.use(protect);

// Template Routes
router.get('/template/latest', diagnosisController.getLatestTemplate);
router.get('/templates/:id', diagnosisController.getTemplateById);

// Supervisor/Admin Only Routes
router.get('/templates', authorize('supervisor', 'admin'), diagnosisController.listTemplates);
router.post('/templates', authorize('supervisor', 'admin'), diagnosisController.createTemplate);
router.put('/templates/:id', authorize('supervisor', 'admin'), diagnosisController.updateTemplate);
router.delete('/templates/:id', authorize('supervisor', 'admin'), diagnosisController.deleteTemplate);
router.post('/reports', diagnosisController.submitReport);
router.get('/reports/session/:sessionId', diagnosisController.getReportBySession);

module.exports = router;
