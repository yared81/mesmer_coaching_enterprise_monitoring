const ReportService = require('../services/report.service');

/**
 * @route   GET /api/v1/reports/enterprise/:id/pdf
 */
exports.exportEnterprisePDF = async (req, res, next) => {
  try {
    const { id } = req.params;
    const pdfBuffer = await ReportService.generateEnterprisePDF(id);

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=MESMER_Enterprise_${id}.pdf`,
      'Content-Length': pdfBuffer.length
    });

    res.send(pdfBuffer);
  } catch (err) {
    next(err);
  }
};

/**
 * @route   GET /api/v1/reports/system/csv
 */
exports.exportSystemCSV = async (req, res, next) => {
  try {
    const csvContent = await ReportService.generateSystemCSV();
    const timestamp = new Date().toISOString().split('T')[0];

    res.set({
      'Content-Type': 'text/csv',
      'Content-Disposition': `attachment; filename=MESMER_Master_List_${timestamp}.csv`
    });

    res.send(csvContent);
  } catch (err) {
    next(err);
  }
};

/**
 * @route   GET /api/v1/reports/weekly
 */
exports.exportWeeklyReport = async (req, res, next) => {
  try {
    const coachId = req.user.userId;
    const pdfBuffer = await ReportService.generateWeeklyActivityReport(coachId);
    const timestamp = new Date().toISOString().split('T')[0];

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=MESMER_Weekly_${timestamp}.pdf`,
      'Content-Length': pdfBuffer.length
    });

    res.send(pdfBuffer);
  } catch (err) {
    next(err);
  }
};
