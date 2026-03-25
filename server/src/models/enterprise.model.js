const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const { encrypt, decrypt } = require('../utils/encryption.util');

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
    allowNull: false,
    get() { return decrypt(this.getDataValue('owner_name')); },
    set(val) { this.setDataValue('owner_name', encrypt(val)); }
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
    type: DataTypes.STRING(128), // Increased for encrypted length
    allowNull: false,
    get() { return decrypt(this.getDataValue('phone')); },
    set(val) { this.setDataValue('phone', encrypt(val)); }
  },
  email: {
    type: DataTypes.STRING(255),
    validate: {
      isEmail: true
    },
    get() { return decrypt(this.getDataValue('email')); },
    set(val) { this.setDataValue('email', encrypt(val)); }
  },
 bitumen
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
  baseline_employees: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  baseline_revenue: {
    type: DataTypes.DECIMAL(15, 2),
    defaultValue: 0.00
  },
  record_keeping_system: {
    type: DataTypes.ENUM('none', 'paper', 'digital', 'professional'),
    allowNull: true
  },
  challenges: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  loan_amount: {
    type: DataTypes.DECIMAL(15, 2),
    defaultValue: 0.00
  },
  consent_status: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  consent_date: {
    type: DataTypes.DATE,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('active', 'pilot', 'stalled', 'graduated', 'dropped'),
    defaultValue: 'active'
  },
  last_activity_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
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
  user_id: {
    type: DataTypes.UUID,
    allowNull: true, // Optional initially, but will be filled on registration
    references: {
      model: 'users',
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
