const enterpriseService = require('../services/enterprise.service');

class GraduationController {
  graduateEnterprise = async (req, res, next) => {
    try {
      const result = await enterpriseService.graduateEnterprise(req.params.id, req.user.userId);
      res.status(200).json({ success: true, data: result });
    } catch (error) { next(error); }
  };
}
module.exports = new GraduationController();
