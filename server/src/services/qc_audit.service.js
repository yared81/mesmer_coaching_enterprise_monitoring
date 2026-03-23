const { QcAudit, Enterprise, CoachingSession, User } = require('../models');
const { Op } = require('sequelize');

class QcAuditService {
  async getPendingAudits() {
    return await QcAudit.findAll({
      where: { status: 'pending' },
      include: [
        { model: Enterprise, as: 'enterprise', attributes: ['business_name'] },
        { model: CoachingSession, as: 'session', attributes: ['title'] }
      ],
      order: [['createdAt', 'DESC']]
    });
  }

  async reviewAudit(auditId, data, verifierId) {
    const audit = await QcAudit.findByPk(auditId);
    if (!audit) throw new Error('QC Audit not found');

    const result = await audit.update({
      status: data.status,
      auditor_comments: data.auditor_comments,
      verifier_id: verifierId
    });

    // 1. Handle Session Failure Notification
    if (audit.target_type === 'session') {
      const session = await CoachingSession.findByPk(audit.target_id);
      if (session) {
        await session.update({ 
          qc_status: data.status === 'passed' ? 'audited_pass' : 'audited_fail',
          qc_feedback: data.auditor_comments || session.qc_feedback
        });

        if (data.status === 'failed') {
          const notificationService = require('./notification.service');
          await notificationService.createNotification({
            userId: session.coach_id,
            title: 'Action Required: Session QC Failed',
            message: `Your session "${session.title}" failed QC verification. Reason: ${data.auditor_comments}`,
            type: 'warning'
          });
        }
      }
    }

    // 2. Handle Baseline Failure Notification
    if (audit.target_type === 'baseline' && data.status === 'failed') {
      const enterprise = await Enterprise.findByPk(audit.target_id);
      if (enterprise) {
        const notificationService = require('./notification.service');
        await notificationService.createNotification({
          userId: enterprise.coach_id,
          title: 'Action Required: Baseline QC Failed',
          message: `The baseline data for "${enterprise.business_name}" failed QC. Reason: ${data.auditor_comments}`,
          type: 'warning'
        });
      }
    }

    return result;
  }

  async getAuditHistory() {
    return await QcAudit.findAll({
      where: { status: { [Op.ne]: 'pending' } },
      include: [
        { model: User, as: 'verifier', attributes: ['name'] },
        { model: Enterprise, as: 'enterprise', attributes: ['business_name'] },
        { model: CoachingSession, as: 'session', attributes: ['title'] }
      ],
      order: [['updatedAt', 'DESC']]
    });
  }
}
module.exports = new QcAuditService();
