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

  /**
   * @route POST /api/v1/auth/logout
   */
  logout = async (req, res, next) => {
    // In a stateless JWT setup, logout is mainly handled by client clearing tokens.
    // For rotation, we could blacklist refresh tokens in Redis here.
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  };
}

module.exports = new AuthController();
