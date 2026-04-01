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
  followup_type: {
    type: DataTypes.ENUM('physical', 'phone'),
    defaultValue: 'physical'
  },
  session_number: {
    type: DataTypes.INTEGER,
    allowNull: true // 1-8 for core visits
  },
  revenue_growth_percent: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0.00
  },
  current_employees: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  jobs_created: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  qc_status: {
    type: DataTypes.ENUM('pending', 'approved', 'flagged'),
    defaultValue: 'pending'
  },
  qc_feedback: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
    defaultValue: 0.0
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
    defaultValue: 0.0
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
