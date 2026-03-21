const ReportService = require('../services/report.service');

/**
 * Controller for handling PDF/CSV report exports
 */
exports.exportEnterprisePDF = async (req, res, next) => {
  try {
    const { id } = req.params;
    const pdfBuffer = await ReportService.generateEnterprisePDF(id);

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=MESMER_Report_${id}.pdf`,
      'Content-Length': pdfBuffer.length
    });

    res.send(pdfBuffer);
  } catch (err) {
    next(err);
  }
};

exports.exportSystemCSV = async (req, res, next) => {
  try {
    const csvContent = await ReportService.generateSystemCSV();

    res.set({
      'Content-Type': 'text/csv',
      'Content-Disposition': 'attachment; filename=MESMER_System_Health.csv'
    });

    res.send(csvContent);
  } catch (err) {
    next(err);
  }
};
