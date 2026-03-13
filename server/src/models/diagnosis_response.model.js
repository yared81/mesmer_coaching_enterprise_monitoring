const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DiagnosisResponse = sequelize.define('DiagnosisResponse', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  report_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_reports',
      key: 'id',
    },
  },
  question_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_questions',
      key: 'id',
    },
  },
  choice_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_choices',
      key: 'id',
    },
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'diagnosis_responses',
  underscored: true,
});

module.exports = DiagnosisResponse;
