const Institution = require('./institution.model');
const User = require('./user.model');
const Enterprise = require('./enterprise.model');

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

const db = {
  Institution,
  User,
  Enterprise
};

module.exports = db;
