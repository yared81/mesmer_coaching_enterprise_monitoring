const { Enterprise } = require('../models');

class VerifyController {
  verifyCertificate = async (req, res, next) => {
    try {
      const { code } = req.params;
      
      const enterprise = await Enterprise.findOne({
        where: { verification_code: code },
        attributes: ['id', 'business_name', 'owner_name', 'status', 'verification_code', 'graduation_date']
      });

      if (!enterprise) {
        return res.status(404).json({
          success: false,
          is_valid: false,
          message: 'Invalid Verification Code'
        });
      }

      res.status(200).json({
        success: true,
        is_valid: true,
        data: enterprise
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new VerifyController();
