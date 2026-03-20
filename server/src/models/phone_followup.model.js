const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const PhoneFollowupLog = sequelize.define('PhoneFollowupLog', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'enterprises',
      key: 'id'
    }
  },
  coach_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  purpose: {
    type: DataTypes.STRING,
    allowNull: false
  },
  issue_addressed: {
    type: DataTypes.TEXT
  },
  advice_given: {
    type: DataTypes.TEXT
  },
  next_action: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'phone_followup_logs',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = PhoneFollowupLog;
