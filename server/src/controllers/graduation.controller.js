const enterpriseService = require('../services/enterprise.service');

class GraduationController {
  getReady = async (req, res, next) => {
    try {
      const list = await enterpriseService.getGraduationReady(req.user.institutionId);
      res.status(200).json({ success: true, data: list });
    } catch (error) { next(error); }
  };

  graduateEnterprise = async (req, res, next) => {
    try {
      const result = await enterpriseService.graduateEnterprise(req.params.id, req.user.userId);
      res.status(200).json({ success: true, data: result });
    } catch (error) { next(error); }
  };

  verifyCertificate = async (req, res, next) => {
    try {
      const result = await enterpriseService.verifyCertificate(req.params.code);
      res.status(200).json({ success: true, data: result });
    } catch (error) { next(error); }
  };
}
module.exports = new GraduationController();
