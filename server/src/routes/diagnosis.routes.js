const express = require('express');
const router = express.Router();
const diagnosisController = require('../controllers/diagnosis.controller');
const { protect, authorize, restrictToOwnEnterprise } = require('../middleware/auth.middleware');

// All diagnosis routes require authentication
router.use(protect);

// Template Routes
router.get('/template/latest', diagnosisController.getLatestTemplate);
router.get('/templates/:id', diagnosisController.getTemplateById);

// Admin/Supervisor/Role-specific Routes
router.get('/templates', authorize('super_admin', 'supervisor', 'admin', 'coach', 'me_officer', 'program_manager', 'regional_coordinator'), diagnosisController.listTemplates);
router.post('/templates', authorize('super_admin', 'supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.createTemplate);
router.put('/templates/:id', authorize('super_admin', 'supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.updateTemplate);
router.delete('/templates/:id', authorize('super_admin', 'supervisor', 'admin', 'me_officer', 'program_manager'), diagnosisController.deleteTemplate);
router.post('/reports', diagnosisController.submitReport);
router.get('/reports/session/:sessionId', diagnosisController.getReportBySession);
router.get('/enterprise/:enterpriseId/performance', authorize('super_admin', 'admin', 'supervisor', 'coach', 'enterprise', 'me_officer', 'program_manager', 'regional_coordinator'), restrictToOwnEnterprise, diagnosisController.getEnterprisePerformance);

module.exports = router;
