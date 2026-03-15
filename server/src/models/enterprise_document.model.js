const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const EnterpriseDocument = sequelize.define('EnterpriseDocument', {
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
  session_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'coaching_sessions',
      key: 'id'
    }
  },
  uploader_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  file_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  file_url: {
    type: DataTypes.STRING,
    allowNull: false
  },
  file_type: {
    type: DataTypes.STRING,
    allowNull: true
  },
  document_type: {
    type: DataTypes.STRING,
    defaultValue: 'evidence' // e.g., 'evidence', 'certificate', 'license'
  }
}, {
  tableName: 'enterprise_documents',
  timestamps: true,
  createdAt: 'uploaded_at',
  updatedAt: false
});

module.exports = EnterpriseDocument;
