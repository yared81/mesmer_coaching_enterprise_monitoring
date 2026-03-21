const jwt = require('jsonwebtoken');

const protect = (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized to access this route'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized to access this route'
    });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `User role ${req.user.role} is not authorized to access this route`
      });
    }
    next();
  };
};

const restrictToOwnEnterprise = (req, res, next) => {
  if (req.user.role === 'enterprise_user') {
    const requestedId = req.params.enterpriseId || req.body.enterprise_id || req.query.enterprise_id;
    if (requestedId && requestedId !== req.user.enterprise_id) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized: Enterprise Users can only access their own data'
      });
    }
  }
  next();
};

const restrictToSelfOrAdmin = (req, res, next) => {
  const userId = req.params.id || req.body.user_id;
  if (req.user.role !== 'super_admin' && req.user.role !== 'admin' && req.user.id !== userId) {
    return res.status(403).json({
      success: false,
      message: 'Unauthorized: You can only access your own accounts/data'
    });
  }
  next();
};

module.exports = { protect, authorize, restrictToOwnEnterprise, restrictToSelfOrAdmin };

