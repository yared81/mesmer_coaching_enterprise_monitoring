const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Institution = sequelize.define('Institution', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  region: {
    type: DataTypes.STRING
  },
  contact_email: {
    type: DataTypes.STRING,
    validate: {
      isEmail: true
    }
  }
}, {
  tableName: 'institutions',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false // Based on SQL schema, only created_at is present
});

module.exports = Institution;
