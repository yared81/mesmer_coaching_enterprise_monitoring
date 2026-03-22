const { QcAudit, Enterprise, CoachingSession, User } = require('../models');
const { Op } = require('sequelize');

class QcAuditService {
  async getPendingAudits() {
    return await QcAudit.findAll({
      where: { status: 'pending' },
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

    // If it's a session and it fails, we should update the session status so the coach knows
    if (audit.target_type === 'session') {
      const session = await CoachingSession.findByPk(audit.target_id);
      if (session) {
        await session.update({ 
          qc_status: data.status === 'passed' ? 'audited_pass' : 'audited_fail',
          qc_feedback: data.auditor_comments || session.qc_feedback
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
