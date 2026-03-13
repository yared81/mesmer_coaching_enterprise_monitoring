const diagnosisService = require('../services/diagnosis.service');

class DiagnosisController {
  /**
   * @route GET /api/v1/diagnosis/template/latest
   * @access Coach, Supervisor, Admin
   */
  getLatestTemplate = async (req, res, next) => {
    try {
      const { institutionId } = req.user;
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
      const { institutionId } = req.user;
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
      const { institutionId } = req.user;
      const template = await diagnosisService.createTemplate(req.body, institutionId);
      
      res.status(201).json({
        success: true,
        data: template
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new DiagnosisController();
