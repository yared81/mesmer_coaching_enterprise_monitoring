const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  type: {
    type: DataTypes.STRING,
    defaultValue: 'info' // info, alert, success
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  institution_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'institutions',
      key: 'id'
    }
  }
}, {
  tableName: 'notifications',
  underscored: true,
  timestamps: true
});

module.exports = Notification;
