const userManagementService = require('../services/user_management.service');
const institutionManagementService = require('../services/institution_management.service');

class UserManagementController {
  // --- User Management ---

  getUsers = async (req, res, next) => {
    try {
      const users = await userManagementService.getUsers(req.query);
      res.status(200).json({
        success: true,
        data: users
      });
    } catch (error) {
      next(error);
    }
  };

  createUser = async (req, res, next) => {
    try {
      const user = await userManagementService.createUser(req.body);
      res.status(201).json({
        success: true,
        data: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      });
    } catch (error) {
      next(error);
    }
  };

  updateUser = async (req, res, next) => {
    try {
      const user = await userManagementService.updateUser(req.params.id, req.body);
      res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      next(error);
    }
  };

  toggleUserStatus = async (req, res, next) => {
    try {
      const user = await userManagementService.toggleUserStatus(req.params.id);
      res.status(200).json({
        success: true,
        data: {
          id: user.id,
          is_active: user.is_active
        }
      });
    } catch (error) {
      next(error);
    }
  };

  // --- Institution Management ---

  getInstitutions = async (req, res, next) => {
    try {
      const institutions = await institutionManagementService.getInstitutions(req.query);
      res.status(200).json({
        success: true,
        data: institutions
      });
    } catch (error) {
      next(error);
    }
  };

  createInstitution = async (req, res, next) => {
    try {
      const institution = await institutionManagementService.createInstitution(req.body);
      res.status(201).json({
        success: true,
        data: institution
      });
    } catch (error) {
      next(error);
    }
  };

  updateInstitution = async (req, res, next) => {
    try {
      const institution = await institutionManagementService.updateInstitution(req.params.id, req.body);
      res.status(200).json({
        success: true,
        data: institution
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new UserManagementController();
