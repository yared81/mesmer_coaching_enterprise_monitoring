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

    console.log('✅ Schema Fix Applied');
    process.exit(0);
  } catch (err) {
    console.error('❌ Schema Fix Failed:', err);
    process.exit(1);
  }
}

fixSchema();
