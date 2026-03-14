const diagnosisService = require('../services/diagnosis.service');

class DiagnosisController {
  /**
   * @route GET /api/v1/diagnosis/template/latest
   * @access Coach, Supervisor, Admin
   */
  getLatestTemplate = async (req, res, next) => {
    try {
      const institutionId = req.user.institution_id || req.user.institutionId;
      const template = await diagnosisService.getLatestTemplate(institutionId);
      
      if (!template) {
        return res.status(404).json({
          success: false,
          message: 'No active diagnosis template found.'
        });
      }

      res.status(200).json({
        success: true,
        data: template
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/diagnosis/templates
   * @access Supervisor, Admin
   */
  listTemplates = async (req, res, next) => {
    try {
      const institutionId = req.user.institution_id || req.user.institutionId;
      const templates = await diagnosisService.listTemplates(institutionId);
      
      res.status(200).json({
        success: true,
        data: templates
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route POST /api/v1/diagnosis/templates
   * @access Supervisor, Admin
   */
  createTemplate = async (req, res, next) => {
    try {
      const institutionId = req.user.institution_id || req.user.institutionId;
      const template = await diagnosisService.createTemplate(req.body, institutionId);
      
      res.status(201).json({
        success: true,
        data: template
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route PUT /api/v1/diagnosis/templates/:id
   * @access Supervisor, Admin
   */
  updateTemplate = async (req, res, next) => {
    try {
      const institutionId = req.user.institution_id || req.user.institutionId;
      const template = await diagnosisService.updateTemplate(req.params.id, req.body, institutionId);
      
      res.status(200).json({
        success: true,
        data: template
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route POST /api/v1/diagnosis/reports
   * @access Coach, Supervisor, Admin
   */
  submitReport = async (req, res, next) => {
    try {
      const report = await diagnosisService.submitReport(req.body);
      
      res.status(201).json({
        success: true,
        data: report
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/diagnosis/reports/session/:sessionId
   * @access Coach, Supervisor, Admin
   */
  getReportBySession = async (req, res, next) => {
    try {
      const { sessionId } = req.params;
      const report = await diagnosisService.getReportBySessionId(sessionId);
      
      res.status(200).json({
        success: true,
        data: report
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new DiagnosisController();
