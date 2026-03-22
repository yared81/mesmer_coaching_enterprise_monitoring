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
    console.log(`[AUTH-DEBUG] authorize middleware check on ${req.method} ${req.url}`);
    console.log(`[AUTH-DEBUG] Required Roles:`, roles);
    console.log(`[AUTH-DEBUG] Provided Role: '${req.user.role}'`);
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
    const requestedId = req.params.id || req.params.enterpriseId || req.body.enterprise_id || req.query.enterprise_id;
    console.log(`[AUTH-DEBUG] restrictToOwnEnterprise check: requested=${requestedId}, user_ent=${req.user.enterprise_id}`);
    if (requestedId && requestedId !== req.user.enterprise_id) {
      console.warn(`[AUTH-DEBUG] Blocked access: User ${req.user.id} tried to access enterprise ${requestedId}`);
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

