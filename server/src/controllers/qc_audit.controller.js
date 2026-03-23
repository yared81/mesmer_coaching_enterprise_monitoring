const qcAuditService = require('../services/qc_audit.service');

class QcAuditController {
  getPendingAudits = async (req, res, next) => {
    try {
      const audits = await qcAuditService.getPendingAudits();
      res.status(200).json({ success: true, data: audits });
    } catch (error) { next(error); }
  };

  reviewAudit = async (req, res, next) => {
    try {
      const audit = await qcAuditService.reviewAudit(req.params.id, req.body, req.user.userId);
      res.status(200).json({ success: true, data: audit });
    } catch (error) { next(error); }
  };

  getAuditById = async (req, res, next) => {
    try {
      const audit = await qcAuditService.getAuditById(req.params.id);
      res.status(200).json({ success: true, data: audit });
    } catch (error) { next(error); }
  };

  getAuditHistory = async (req, res, next) => {
    try {
      const audits = await qcAuditService.getAuditHistory();
      res.status(200).json({ success: true, data: audits });
    } catch (error) { next(error); }
  };
}
module.exports = new QcAuditController();
