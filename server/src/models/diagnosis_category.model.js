const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DiagnosisCategory = sequelize.define('DiagnosisCategory', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  template_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'diagnosis_templates',
      key: 'id'
    }
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'diagnosis_categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = DiagnosisCategory;
