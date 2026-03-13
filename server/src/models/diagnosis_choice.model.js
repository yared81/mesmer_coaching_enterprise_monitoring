const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DiagnosisChoice = sequelize.define('DiagnosisChoice', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  question_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_questions',
      key: 'id'
    }
  },
  text: {
    type: DataTypes.STRING,
    allowNull: false
  },
  points: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'diagnosis_choices',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = DiagnosisChoice;
