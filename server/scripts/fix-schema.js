const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const { sequelize } = require('../src/config/database');

async function fixSchema() {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    console.log('Adding updated_at to enterprises...');
    await sequelize.query('ALTER TABLE enterprises ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;');

    console.log('Adding updated_at to users...');
    await sequelize.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;');

    console.log('Adding updated_at to institutions...');
    await sequelize.query('ALTER TABLE institutions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;');

    console.log('Adding missing columns to coaching_sessions...');
    await sequelize.query('ALTER TABLE coaching_sessions ADD COLUMN IF NOT EXISTS title VARCHAR(255);');
    await sequelize.query('ALTER TABLE coaching_sessions ADD COLUMN IF NOT EXISTS session_type VARCHAR(50) DEFAULT \'coaching\';');
    await sequelize.query('ALTER TABLE coaching_sessions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;');

    console.log('✅ Schema Fix Applied');
    process.exit(0);
  } catch (err) {
    console.error('❌ Schema Fix Failed:', err);
    process.exit(1);
  }
}

fixSchema();
