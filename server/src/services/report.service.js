const PDFDocument = require('pdfkit');
const { Parser } = require('json2csv');
const { Enterprise, CoachingSession, IAP, IAPTask, User } = require('../models');
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
          model: IAP, 
          as: 'actionPlans',
          include: [{ model: IAPTask, as: 'tasks' }]
        }
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

      // --- Header ---
      doc.fillColor('#111827').fontSize(24).text('MESMER Coaching Progress Report', { align: 'center' });
      doc.moveDown();
      doc.fontSize(10).fillColor('#6B7280').text(`Generated on: ${new Date().toLocaleDateString()}`, { align: 'right' });
      doc.moveDown(2);

      // --- Enterprise Details ---
      doc.fillColor('#111827').fontSize(16).text('Enterprise Profile', { underline: true });
      doc.moveDown(0.5);
      doc.fontSize(12).fillColor('#374151');
      doc.text(`Name: ${enterprise.business_name}`);
      doc.text(`Sector: ${enterprise.sector || 'N/A'}`);
      doc.text(`Contact: ${enterprise.owner_name} (${enterprise.owner_phone || 'No phone'})`);
      doc.text(`Location: ${enterprise.location_name || 'N/A'}`);
      doc.moveDown();

      // --- Current Goals (IAP) ---
      doc.fontSize(16).fillColor('#111827').text('Interactive Action Plan (IAP) Status', { underline: true });
      doc.moveDown(0.5);
      
      if (enterprise.actionPlans && enterprise.actionPlans.length > 0) {
        const activeIap = enterprise.actionPlans[0]; // Take most recent
        const totalTasks = activeIap.tasks.length;
        const completedTasks = activeIap.tasks.filter(t => t.status === 'completed').length;
        const progress = totalTasks > 0 ? (completedTasks / totalTasks * 100).toFixed(1) : 0;

        doc.fontSize(12).text(`Current Objective: ${activeIap.title}`);
        doc.text(`Overall Progress: ${progress}% (${completedTasks}/${totalTasks} tasks completed)`);
        doc.moveDown(0.5);
        
        activeIap.tasks.forEach((task, index) => {
          const statusColor = task.status === 'completed' ? '#059669' : '#D1D5DB';
          doc.fillColor(statusColor).fontSize(10).text(`${index + 1}. [${task.status.toUpperCase()}] ${task.title}`);
        });
      } else {
        doc.fontSize(11).fillColor('#9CA3AF').text('No active Action Plan found.');
      }
      doc.moveDown();

      // --- Coaching History ---
      doc.fontSize(16).fillColor('#111827').text('Recent Coaching Sessions', { underline: true });
      doc.moveDown(0.5);

      if (enterprise.sessions && enterprise.sessions.length > 0) {
        enterprise.sessions.slice(0, 10).forEach((session) => {
          doc.fillColor('#374151').fontSize(11).text(`${new Date(session.scheduled_date).toLocaleDateString()} - ${session.title}`);
          doc.fillColor('#6B7280').fontSize(9).text(`Type: ${session.session_type} | Notes: ${session.notes || 'No notes provided'}`);
          doc.moveDown(0.5);
        });
      } else {
        doc.fontSize(11).fillColor('#9CA3AF').text('No coaching sessions recorded yet.');
      }

      // --- Footer ---
      const pageCount = doc.bufferedPageRange().count;
      for (let i = 0; i < pageCount; i++) {
        doc.switchToPage(i);
        doc.fontSize(8).fillColor('#9CA3AF').text(
          `MESMER Monitoring System | Page ${i + 1} of ${pageCount}`,
          50,
          doc.page.height - 50,
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
          model: IAP, 
          as: 'actionPlans',
          include: [{ model: IAPTask, as: 'tasks' }]
        }
      ]
    });

    const data = enterprises.map(ent => {
      const activeIap = ent.actionPlans?.[0];
      const totalTasks = activeIap?.tasks?.length || 0;
      const completedTasks = activeIap?.tasks?.filter(t => t.status === 'completed').length || 0;
      const progress = totalTasks > 0 ? (completedTasks / totalTasks * 100).toFixed(1) : 0;

      return {
        'Enterprise ID': ent.id,
        'Business Name': ent.business_name,
        'Owner': ent.owner_name,
        'Sector': ent.sector,
        'Region': ent.location_name,
        'IAP Progress %': progress,
        'Tasks Completed': completedTasks,
        'Total Tasks': totalTasks,
        'Created At': ent.created_at
      };
    });

    const json2csvParser = new Parser();
    return json2csvParser.parse(data);
  }
}

module.exports = new ReportService();
