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

    // Add enterprise columns if they don't exist
    const enterpriseColumns = [
      { name: 'business_age', type: require('sequelize').DataTypes.INTEGER, defaultValue: 0 },
      { name: 'owner_gender', type: require('sequelize').DataTypes.ENUM('male', 'female', 'other') },
      { name: 'premise_type', type: require('sequelize').DataTypes.ENUM('rented', 'owned', 'home_based', 'other') },
      { name: 'baseline_score', type: require('sequelize').DataTypes.DECIMAL(3, 2), defaultValue: 0.0 },
      { name: 'user_id', type: require('sequelize').DataTypes.UUID, references: { model: 'users', key: 'id' } }
    ];

    for (const col of enterpriseColumns) {
      await sequelize.getQueryInterface().addColumn('enterprises', col.name, {
        type: col.type,
        allowNull: true,
        defaultValue: col.defaultValue,
        references: col.references
      }).catch(err => {
        if (err.message.includes('already exists')) {
          console.log(`✅ Column enterprises.${col.name} already exists.`);
        } else {
          console.warn(`⚠️ Could not add column ${col.name}:`, err.message);
        }
      });
    }

    console.log('🚀 Database schema fix completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('💥 Failed to fix schema:', error.message);
    process.exit(1);
  }
}

fixSchema();
