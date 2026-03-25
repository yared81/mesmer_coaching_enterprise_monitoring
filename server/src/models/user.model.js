const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs');
const { encrypt, decrypt } = require('../utils/encryption.util');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  email: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    validate: {
      isEmail: true
    }
  },
  password_hash: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  name: {
    type: DataTypes.STRING(128),
    allowNull: false,
    get() { return decrypt(this.getDataValue('name')); },
    set(val) { this.setDataValue('name', encrypt(val)); }
  },
  role: {
    type: DataTypes.ENUM(
      'super_admin', 'program_manager', 'regional_coordinator',
      'me_officer', 'data_verifier', 'trainer', 'coach',
      'enumerator', 'comms_officer', 'enterprise_user', 'stakeholder'
    ),
    allowNull: false
  },
  institution_id: {
    type: DataTypes.UUID,
    references: {
      model: 'institutions',
      key: 'id'
    }
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  phone: {
    type: DataTypes.STRING(128),
    allowNull: true,
    get() { return decrypt(this.getDataValue('phone')); },
    set(val) { this.setDataValue('phone', encrypt(val)); }
  },
  token_version: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'users',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

// Instance method to check password
User.prototype.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password_hash);
};

// Static method to hash password
User.hashPassword = async function (password) {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

module.exports = User;
