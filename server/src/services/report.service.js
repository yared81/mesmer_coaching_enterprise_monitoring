const PDFDocument = require('pdfkit');
const { Parser } = require('json2csv');
const { Enterprise, CoachingSession, IndividualActionPlan, IapTask, User, sequelize } = require('../models');
const { Op } = require('sequelize');

class ReportService {
  /**
   * Generates a professional PDF report for a single enterprise
   */
  async generateEnterprisePDF(enterpriseId) {
    const enterprise = await Enterprise.findByPk(enterpriseId, {
      include: [
        { model: CoachingSession, as: 'sessions' },
        {
          model: IndividualActionPlan,
          as: 'actionPlans',
          include: [{ model: IapTask, as: 'tasks' }]
        },
        { model: User, as: 'coach', attributes: ['name', 'email'] }
      ],
      order: [
        [{ model: CoachingSession, as: 'sessions' }, 'scheduled_date', 'DESC']
      ]
    });

    if (!enterprise) throw new Error('Enterprise not found');

    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ margin: 50 });
      let buffers = [];
      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', reject);

      // ── Header ─────────────────────────────────────────────────────────────
      doc.fillColor('#111827').fontSize(22).text('MESMER Coaching Progress Report', { align: 'center' });
      doc.moveDown(0.25);
      doc.fontSize(10).fillColor('#6B7280').text(`Generated: ${new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`, { align: 'center' });
      doc.moveDown(1.5);

      // ── Enterprise Profile ──────────────────────────────────────────────────
      doc.fillColor('#111827').fontSize(14).text('Enterprise Profile', { underline: true });
      doc.moveDown(0.5);
      doc.fontSize(11).fillColor('#374151');

      const rows = [
        ['Business Name',      enterprise.business_name],
        ['Owner',              enterprise.owner_name],
        ['Owner Age',          enterprise.owner_age != null ? `${enterprise.owner_age} yrs` : 'N/A'],
        ['Business Activity',  enterprise.business_activity || 'N/A'],
        ['Sector',             enterprise.sector || 'N/A'],
        ['Location',           enterprise.location || 'N/A'],
        ['Employees',          String(enterprise.employee_count ?? 0)],
        ['Baseline Revenue',   enterprise.baseline_revenue != null ? `ETB ${Number(enterprise.baseline_revenue).toLocaleString()}` : 'N/A'],
        ['Program Status',     (enterprise.status || 'active').toUpperCase()],
        ['Assigned Coach',     enterprise.coach?.name || 'N/A'],
        ['Registered',         enterprise.registered_at ? new Date(enterprise.registered_at).toLocaleDateString('en-GB') : 'N/A'],
      ];

      rows.forEach(([label, value]) => {
        doc.text(`${label}: `, { continued: true }).fillColor('#1F2937').text(value).fillColor('#374151');
      });

      doc.moveDown(1);

      // ── IAP Status ─────────────────────────────────────────────────────────
      doc.fillColor('#111827').fontSize(14).text('Interactive Action Plan (IAP) Status', { underline: true });
      doc.moveDown(0.5);

      if (enterprise.actionPlans && enterprise.actionPlans.length > 0) {
        const activeIap = enterprise.actionPlans[0];
        const totalTasks = activeIap.tasks.length;
        const completedTasks = activeIap.tasks.filter(t => t.status === 'completed').length;
        const progress = totalTasks > 0 ? (completedTasks / totalTasks * 100).toFixed(1) : 0;

        doc.fontSize(11).fillColor('#374151').text(`Objective: ${activeIap.title}`);
        doc.text(`Progress: ${progress}% (${completedTasks}/${totalTasks} tasks completed)`);
        doc.moveDown(0.5);

        activeIap.tasks.forEach((task, index) => {
          const isDone = task.status === 'completed';
          doc.fillColor(isDone ? '#059669' : '#9CA3AF')
            .fontSize(10)
            .text(`  ${index + 1}. [${task.status.toUpperCase()}] ${task.title}`);
        });
      } else {
        doc.fontSize(11).fillColor('#9CA3AF').text('No active Action Plan found.');
      }

      doc.moveDown(1);

      // ── Coaching History ────────────────────────────────────────────────────
      doc.fillColor('#111827').fontSize(14).text('Recent Coaching Sessions', { underline: true });
      doc.moveDown(0.5);

      if (enterprise.sessions && enterprise.sessions.length > 0) {
        enterprise.sessions.slice(0, 10).forEach(session => {
          const date = session.scheduled_date
            ? new Date(session.scheduled_date).toLocaleDateString('en-GB')
            : 'N/A';
          doc.fillColor('#374151').fontSize(11).text(`${date} — ${session.title}`);
          doc.fillColor('#6B7280').fontSize(9).text(
            `Type: ${session.session_type}  |  Status: ${session.status}  |  Notes: ${session.notes || 'None'}`
          );
          doc.moveDown(0.4);
        });
      } else {
        doc.fontSize(11).fillColor('#9CA3AF').text('No coaching sessions recorded yet.');
      }

      // ── Footer ─────────────────────────────────────────────────────────────
      const range = doc.bufferedPageRange();
      for (let i = 0; i < range.count; i++) {
        doc.switchToPage(i);
        doc.fontSize(8).fillColor('#9CA3AF').text(
          `MESMER Monitoring System  |  Confidential  |  Page ${i + 1} of ${range.count}`,
          50,
          doc.page.height - 40,
          { align: 'center' }
        );
      }

      doc.end();
    });
  }

  /**
   * Generates a system-wide CSV report of all enterprises
   */
  async generateSystemCSV(filters = {}) {
    const enterprises = await Enterprise.findAll({
      include: [
        {
          model: IndividualActionPlan,
          as: 'actionPlans',
          include: [{ model: IapTask, as: 'tasks' }]
        },
        { model: User, as: 'coach', attributes: ['name'] }
      ]
    });

    const data = enterprises.map(ent => {
      const activeIap = ent.actionPlans?.[0];
      const totalTasks = activeIap?.tasks?.length || 0;
      const completedTasks = activeIap?.tasks?.filter(t => t.status === 'completed').length || 0;
      const progress = totalTasks > 0 ? (completedTasks / totalTasks * 100).toFixed(1) : 0;

      return {
        'Enterprise ID':       ent.id,
        'Business Name':       ent.business_name,
        'Owner':               ent.owner_name,
        'Owner Age':           ent.owner_age ?? 'N/A',
        'Business Activity':   ent.business_activity || 'N/A',
        'Sector':              ent.sector,
        'Location':            ent.location,
        'Status':              ent.status,
        'Employees':           ent.employee_count,
        'Baseline Revenue':    ent.baseline_revenue,
        'Record Keeping':      ent.record_keeping_system || 'N/A',
        'Assigned Coach':      ent.coach?.name || 'N/A',
        'IAP Progress %':      progress,
        'Tasks Completed':     completedTasks,
        'Total Tasks':         totalTasks,
        'Registered At':       ent.registered_at
      };
    });

    const json2csvParser = new Parser();
    return json2csvParser.parse(data);
  }

  /**
   * Generates a weekly activity summary for a specific coach (last 7 days)
   */
  async generateWeeklyActivityReport(coachId) {
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    const [newEnterprises, sessions] = await Promise.all([
      Enterprise.findAll({
        where: {
          coach_id: coachId,
          registered_at: { [Op.gte]: sevenDaysAgo }
        },
        attributes: ['id', 'business_name', 'sector', 'registered_at']
      }),
      CoachingSession.findAll({
        where: {
          coach_id: coachId,
          scheduled_date: { [Op.gte]: sevenDaysAgo }
        },
        include: [
          { model: Enterprise, as: 'enterprise', attributes: ['business_name'] }
        ],
        order: [['scheduled_date', 'ASC']]
      })
    ]);

    const completedSessions = sessions.filter(s => s.status === 'completed');
    const pendingSessions   = sessions.filter(s => s.status !== 'completed');

    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ margin: 50 });
      let buffers = [];
      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', reject);

      const weekLabel = `${sevenDaysAgo.toLocaleDateString('en-GB')} – ${new Date().toLocaleDateString('en-GB')}`;

      // ── Header ──
      doc.fillColor('#111827').fontSize(22).text('MESMER — Weekly Coach Activity Summary', { align: 'center' });
      doc.moveDown(0.25);
      doc.fontSize(10).fillColor('#6B7280').text(`Reporting Period: ${weekLabel}`, { align: 'center' });
      doc.moveDown(1.5);

      // ── KPI Strip ──
      doc.fillColor('#111827').fontSize(14).text('Week at a Glance', { underline: true });
      doc.moveDown(0.5);
      doc.fontSize(11).fillColor('#374151');
      doc.text(`New Enterprises Registered:  ${newEnterprises.length}`);
      doc.text(`Sessions Conducted:          ${sessions.length}  (${completedSessions.length} completed, ${pendingSessions.length} pending)`);
      doc.moveDown(1);

      // ── New Registrations ──
      doc.fillColor('#111827').fontSize(14).text('New Enterprise Registrations', { underline: true });
      doc.moveDown(0.5);
      if (newEnterprises.length === 0) {
        doc.fontSize(11).fillColor('#9CA3AF').text('No new enterprises registered this week.');
      } else {
        newEnterprises.forEach((ent, i) => {
          doc.fillColor('#374151').fontSize(11)
            .text(`${i + 1}. ${ent.business_name}  (${ent.sector})`);
        });
      }
      doc.moveDown(1);

      // ── Session Log ──
      doc.fillColor('#111827').fontSize(14).text('Session Log', { underline: true });
      doc.moveDown(0.5);
      if (sessions.length === 0) {
        doc.fontSize(11).fillColor('#9CA3AF').text('No sessions this week.');
      } else {
        sessions.forEach(session => {
          const date = session.scheduled_date
            ? new Date(session.scheduled_date).toLocaleDateString('en-GB')
            : 'N/A';
          const bizName = session.enterprise?.business_name || 'Unknown';
          doc.fillColor('#374151').fontSize(11)
            .text(`${date} — ${session.title} (${bizName})`);
          doc.fillColor('#6B7280').fontSize(9)
            .text(`Status: ${session.status}  |  Type: ${session.session_type}`);
          doc.moveDown(0.3);
        });
      }

      // ── Footer ──
      const range = doc.bufferedPageRange();
      for (let i = 0; i < range.count; i++) {
        doc.switchToPage(i);
        doc.fontSize(8).fillColor('#9CA3AF').text(
          `MESMER Monitoring System  |  Confidential  |  Page ${i + 1} of ${range.count}`,
          50, doc.page.height - 40, { align: 'center' }
        );
      }

      doc.end();
    });
  }
}

module.exports = new ReportService();
