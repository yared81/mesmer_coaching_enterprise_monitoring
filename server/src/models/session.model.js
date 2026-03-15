const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CoachingSession = sequelize.define('CoachingSession', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  enterprise_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'enterprises',
      key: 'id'
    }
  },
  coach_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  scheduled_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  status: {
    type: DataTypes.ENUM('scheduled', 'completed', 'cancelled'),
    defaultValue: 'completed'
  },
  session_type: {
    type: DataTypes.ENUM('assessment', 'coaching', 'review'),
    defaultValue: 'coaching'
  },
  problems_identified: {
    type: DataTypes.TEXT
  },
  recommendations: {
    type: DataTypes.TEXT
  },
  notes: {
    type: DataTypes.TEXT
  },
  template_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'diagnosis_templates',
      key: 'id'
    }
  }
}, {
  tableName: 'coaching_sessions',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = CoachingSession;
