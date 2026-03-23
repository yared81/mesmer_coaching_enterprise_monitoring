const express = require('express');
const router = express.Router();
const qcAuditController = require('../controllers/qc_audit.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.use(protect);

// Only specific roles should be able to do this, mostly data_verifier or admin
router.get('/pending', authorize('super_admin', 'admin', 'data_verifier', 'program_manager', 'me_officer'), qcAuditController.getPendingAudits);
router.get('/history', authorize('super_admin', 'admin', 'data_verifier', 'program_manager', 'me_officer'), qcAuditController.getAuditHistory);
router.put('/:id/review', authorize('super_admin', 'admin', 'data_verifier', 'program_manager', 'me_officer'), qcAuditController.reviewAudit);

module.exports = router;
