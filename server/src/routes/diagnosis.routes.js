const express = require('express');
const router = express.Router();
const diagnosisController = require('../controllers/diagnosis.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

// All diagnosis routes require authentication
router.use(protect);

// Template Routes
router.get('/template/latest', diagnosisController.getLatestTemplate);
router.get('/templates/:id', diagnosisController.getTemplateById);

// Supervisor/Admin Only Routes
router.get('/templates', authorize('supervisor', 'admin', 'coach', 'me_officer', 'program_manager'), diagnosisController.listTemplates);
router.post('/templates', authorize('supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.createTemplate);
router.put('/templates/:id', authorize('supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.updateTemplate);
router.delete('/templates/:id', authorize('supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.deleteTemplate);
router.post('/reports', diagnosisController.submitReport);
router.get('/reports/session/:sessionId', diagnosisController.getReportBySession);
router.get('/enterprise/:enterpriseId/performance', authorize('super_admin', 'admin', 'supervisor', 'coach', 'enterprise_user', 'me_officer', 'program_manager'), restrictToOwnEnterprise, diagnosisController.getEnterprisePerformance);

module.exports = router;
