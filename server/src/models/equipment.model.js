const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Equipment = sequelize.define('Equipment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  serial_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('functional', 'broken', 'lost', 'returned'),
    defaultValue: 'functional',
  },
  received_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  notes: {
    type: DataTypes.TEXT,
  }
}, {
  tableName: 'equipment',
  timestamps: true,
});

module.exports = Equipment;
