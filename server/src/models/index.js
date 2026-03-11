const Institution = require('./institution.model');
const User = require('./user.model');

// Define associations
Institution.hasMany(User, {
  foreignKey: 'institution_id',
  as: 'users'
});

User.belongsTo(Institution, {
  foreignKey: 'institution_id',
  as: 'institution'
});

const db = {
  Institution,
  User
};

module.exports = db;
