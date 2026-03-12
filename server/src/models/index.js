const Institution = require('./institution.model');
const User = require('./user.model');
const Enterprise = require('./enterprise.model');
const CoachingSession = require('./session.model');

// Institution <-> User (1:N)
Institution.hasMany(User, {
  foreignKey: 'institution_id',
  as: 'users'
});

User.belongsTo(Institution, {
  foreignKey: 'institution_id',
  as: 'institution'
});

// User (Coach) <-> Enterprise (1:N)
User.hasMany(Enterprise, {
  foreignKey: 'coach_id',
  as: 'enterprises'
});

Enterprise.belongsTo(User, {
  foreignKey: 'coach_id',
  as: 'coach'
});

// Institution <-> Enterprise (1:N)
Institution.hasMany(Enterprise, {
  foreignKey: 'institution_id',
  as: 'enterprises'
});

Enterprise.belongsTo(Institution, {
  foreignKey: 'institution_id',
  as: 'institution'
});

// CoachingSession Associations
Enterprise.hasMany(CoachingSession, {
  foreignKey: 'enterprise_id',
  as: 'sessions'
});

CoachingSession.belongsTo(Enterprise, {
  foreignKey: 'enterprise_id',
  as: 'enterprise'
});

User.hasMany(CoachingSession, {
  foreignKey: 'coach_id',
  as: 'sessions'
});

CoachingSession.belongsTo(User, {
  foreignKey: 'coach_id',
  as: 'coach'
});

const db = {
  Institution,
  User,
  Enterprise,
  CoachingSession
};

module.exports = db;
