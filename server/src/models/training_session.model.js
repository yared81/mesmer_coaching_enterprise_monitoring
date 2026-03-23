const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const TrainingSession = sequelize.define('TrainingSession', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  module: {
    type: DataTypes.ENUM('bookkeeping', 'marketing', 'customer_service', 'business_planning', 'financial_management', 'other'),
    allowNull: false,
  },
  scheduled_date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  start_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  end_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  capacity: {
    type: DataTypes.INTEGER,
    defaultValue: 20,
  },
  trainer_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('scheduled', 'completed', 'cancelled'),
    defaultValue: 'scheduled',
  }
}, {
  tableName: 'training_sessions',
  timestamps: true,
  underscored: true,
});

module.exports = TrainingSession;
