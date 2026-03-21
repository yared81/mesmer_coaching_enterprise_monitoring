const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const QcAudit = sequelize.define('QcAudit', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  target_type: {
    type: DataTypes.ENUM('baseline', 'session', 'endline'),
    allowNull: false,
  },
  target_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  verifier_id: {
    type: DataTypes.UUID,
    allowNull: true,
  },
  is_random_sample: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  status: {
    type: DataTypes.ENUM('pending', 'passed', 'failed'),
    defaultValue: 'pending',
  },
  auditor_comments: {
    type: DataTypes.TEXT,
  },
  flag_reason: {
    type: DataTypes.STRING,
    allowNull: true,
  }
}, {
  tableName: 'qc_audits',
  timestamps: true,
});

module.exports = QcAudit;
