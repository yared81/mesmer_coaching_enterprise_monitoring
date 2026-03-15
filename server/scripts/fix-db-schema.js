const { sequelize } = require('../src/config/database');
const { CoachingSession } = require('../src/models');

async function fixSchema() {
  try {
    console.log('🔍 Checking database schema...');
    
    // Add template_id column if it doesn't exist
    await sequelize.getQueryInterface().addColumn('coaching_sessions', 'template_id', {
      type: require('sequelize').DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'diagnosis_templates',
        key: 'id'
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL'
    }).catch(err => {
      if (err.message.includes('already exists')) {
        console.log('✅ Column template_id already exists.');
      } else {
        throw err;
      }
    });

    console.log('🚀 Database schema fix completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('💥 Failed to fix schema:', error.message);
    process.exit(1);
  }
}

fixSchema();
