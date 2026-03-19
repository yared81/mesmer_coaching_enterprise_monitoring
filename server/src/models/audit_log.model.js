const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const AuditLog = sequelize.define('AuditLog', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'users', key: 'id' }
  },
  action: {
    type: DataTypes.ENUM('CREATE', 'UPDATE', 'DELETE'),
    allowNull: false
  },
  table_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  record_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  old_data: {
    type: DataTypes.JSON,
    allowNull: true
  },
  new_data: {
    type: DataTypes.JSON,
    allowNull: true
  }
}, {
  tableName: 'audit_logs',
  timestamps: true,
  createdAt: 'timestamp',
  updatedAt: false
});

module.exports = AuditLog;
