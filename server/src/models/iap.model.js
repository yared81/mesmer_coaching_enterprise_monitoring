const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const IndividualActionPlan = sequelize.define('IndividualActionPlan', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'enterprises', key: 'id' }
  },
  coach_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  status: {
    type: DataTypes.ENUM('active', 'completed'),
    defaultValue: 'active'
  },
  signoff_date: {
    type: DataTypes.DATE,
    allowNull: true
  },
  coach_signature: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  owner_signature: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'individual_action_plans',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = IndividualActionPlan;
