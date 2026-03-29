const enterpriseService = require('../services/enterprise.service');

class EnterpriseController {
  /**
   * @route POST /api/v1/enterprises
   */
  register = async (req, res, next) => {
    try {
      // Pilot Mode Gatekeeper
      if (process.env.IS_PILOT_MODE === 'true') {
        const count = await enterpriseService.countEnterprises();
        if (count >= 5) {
          return res.status(403).json({
            success: false,
            message: 'Pilot mode is active: Maximum of 5 test enterprises reached. Registration is locked.'
          });
        }
      }

      // req.user is populated by auth middleware
      const { userId, institutionId } = req.user;
      
      const enterprise = await enterpriseService.registerEnterprise(
        req.body, 
        userId, 
        institutionId
      );

      res.status(201).json({
        success: true,
        data: enterprise
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route POST /api/v1/enterprises/bulk
   */
  bulkRegister = async (req, res, next) => {
    try {
      const { enterprises } = req.body;
      if (!Array.isArray(enterprises)) {
        return res.status(400).json({
          success: false,
          message: 'Payload must contain an "enterprises" array'
        });
      }
 
      const { userId, institutionId } = req.user;
      
      const results = await enterpriseService.bulkRegisterEnterprises(
        enterprises, 
        userId, 
        institutionId
      );
 
      res.status(201).json({
        success: true,
        count: results.length,
        data: results
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/enterprises
   */
  list = async (req, res, next) => {
    try {
      const { userId, role, institution_id: institutionId } = req.user;
      const filters = { ...req.query };

      // Enforce Role-Based Data Isolation
      if (role === 'coach') {
        filters.coach_id = userId;
      } else if (role === 'supervisor' || role === 'regional_coordinator') {
        filters.institution_id = institutionId;
      } else if (role === 'enterprise') {
        filters.user_id = userId;
      }
      // Admins see everything (no filter added)

      const result = await enterpriseService.getEnterprises(filters);
      res.status(200).json({
        success: true,
        ...result
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/enterprises/:id
   */
  getById = async (req, res, next) => {
    try {
      const enterprise = await enterpriseService.getEnterpriseById(req.params.id);
      res.status(200).json({
        success: true,
        data: enterprise
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route PUT /api/v1/enterprises/:id
   */
  update = async (req, res, next) => {
    try {
      const enterprise = await enterpriseService.updateEnterprise(req.params.id, req.body, req.user.userId);
      res.status(200).json({
        success: true,
        data: enterprise
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/enterprises/:id/trends
   */
  getTrends = async (req, res, next) => {
    try {
      const trends = await enterpriseService.getGrowthTrends(req.params.id);
      res.status(200).json({
        success: true,
        data: trends
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new EnterpriseController();
