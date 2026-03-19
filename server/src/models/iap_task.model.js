const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const IapTask = sequelize.define('IapTask', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  iap_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'individual_action_plans', key: 'id' }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  deadline: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'completed'),
    defaultValue: 'pending'
  },
  evidence_url: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'iap_tasks',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = IapTask;
