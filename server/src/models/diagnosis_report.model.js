const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DiagnosisReport = sequelize.define('DiagnosisReport', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  session_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'coaching_sessions',
      key: 'id',
    },
  },
  template_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_templates',
      key: 'id',
    },
  },
  total_score: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
  },
  max_score: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
  },
  health_percentage: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
  },
  category_scores: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '{ categoryName: { score, max, percentage } }'
  },
  primary_challenges: {
    type: DataTypes.JSONB,
    defaultValue: [],
    comment: 'List of { questionId, text, choiceText, points } for critical issues'
  },
}, {
  tableName: 'diagnosis_reports',
  underscored: true,
});

module.exports = DiagnosisReport;
