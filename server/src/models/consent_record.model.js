const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ConsentRecord = sequelize.define('ConsentRecord', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  recorded_by: {
    type: DataTypes.UUID,
    allowNull: false, // staff/enumerator who captured it
  },
  consent_version: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: '1.0', // versioned notice
  },
  method: {
    type: DataTypes.ENUM('checkbox', 'verbal', 'signature'),
    allowNull: false,
    defaultValue: 'checkbox',
  },
  is_consented: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
  },
  safeguarding_acknowledged: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
  },
  signed_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  }
}, {
  tableName: 'consent_records',
  timestamps: true,
  underscored: true,
});

module.exports = ConsentRecord;
