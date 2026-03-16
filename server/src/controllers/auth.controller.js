const authService = require('../services/auth.service');

class AuthController {
  /**
   * @route POST /api/v1/auth/login
   */
  login = async (req, res, next) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Please provide email and password'
        });
      }

      const result = await authService.login(email, password);

      res.status(200).json({
        success: true,
        ...result
      });
    } catch (error) {
      res.status(401).json({
        success: false,
        message: error.message
      });
    }
  };

  /**
   * @route GET /api/v1/auth/me
   */
  getMe = async (req, res, next) => {
    try {
      // req.user is populated by auth middleware
      const user = await authService.getMe(req.user.userId);
      res.status(200).json({
        success: true,
        user
      });
    } catch (error) {
      next(error);
    }
  };

  logout = async (req, res, next) => {
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  };

  /**
   * @route PUT /api/v1/auth/profile
   */
  updateProfile = async (req, res, next) => {
    try {
      const { name, email } = req.body;
      console.log(`[DEBUG] Updating profile for user ${req.user.userId}: name=${name}, email=${email}`);
      await authService.updateProfile(req.user.userId, { name, email });
      
      // Re-fetch full user with institution info
      const user = await authService.getMe(req.user.userId);
      console.log(`[DEBUG] Profile updated successfully. Institution: ${user.institution ? user.institution.name : 'NONE'}`);
      
      res.status(200).json({
        success: true,
        data: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          institution_id: user.institution_id,
          institution: user.institution ? user.institution.name : null
        },
        message: 'Profile updated successfully'
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  };
}

module.exports = new AuthController();
