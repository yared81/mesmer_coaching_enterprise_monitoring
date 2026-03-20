
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const TrainingAttendance = sequelize.define('TrainingAttendance', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  training_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  attended: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  feedback_score: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: { min: 1, max: 5 }
  }
}, {
  tableName: 'training_attendance',
  timestamps: true,
});

module.exports = TrainingAttendance;
