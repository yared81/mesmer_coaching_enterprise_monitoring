const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Enterprise = sequelize.define('Enterprise', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  business_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  owner_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  sector: {
    type: DataTypes.ENUM('agriculture', 'manufacturing', 'trade', 'services', 'construction', 'other'),
    allowNull: false
  },
  employee_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    validate: {
      isEmail: true
    }
  },
  business_age: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 0
  },
  owner_gender: {
    type: DataTypes.ENUM('male', 'female', 'other'),
    allowNull: true
  },
  premise_type: {
    type: DataTypes.ENUM('rented', 'owned', 'home_based', 'other'),
    allowNull: true
  },
  baseline_score: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: true,
    defaultValue: 0.0
  },
  coach_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  institution_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'institutions',
      key: 'id'
    }
  },
  registered_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'enterprises',
  timestamps: true,
  createdAt: 'registered_at',
  updatedAt: 'updated_at'
});

module.exports = Enterprise;
