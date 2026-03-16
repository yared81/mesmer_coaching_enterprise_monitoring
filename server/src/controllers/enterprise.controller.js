const enterpriseService = require('../services/enterprise.service');

class EnterpriseController {
  /**
   * @route POST /api/v1/enterprises
   */
  register = async (req, res, next) => {
    try {
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
   * @route GET /api/v1/enterprises
   */
  list = async (req, res, next) => {
    try {
      const { userId, role, institutionId } = req.user;
      const filters = { ...req.query };

      // Enforce Role-Based Data Isolation
      if (role === 'coach') {
        filters.coach_id = userId;
      } else if (role === 'supervisor') {
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
      const enterprise = await enterpriseService.updateEnterprise(req.params.id, req.body);
      res.status(200).json({
        success: true,
        data: enterprise
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new EnterpriseController();
