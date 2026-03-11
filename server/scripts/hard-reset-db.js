const { sequelize } = require('../src/config/database');

async function hardReset() {
  try {
    await sequelize.authenticate();
    console.log('🔗 Connected to Database for Hard Reset');

    // 1. Drop tables in order (cascade)
    console.log('🗑️ Dropping tables...');
    await sequelize.query('DROP TABLE IF EXISTS "enterprises" CASCADE;');
    await sequelize.query('DROP TABLE IF EXISTS "users" CASCADE;');
    await sequelize.query('DROP TABLE IF EXISTS "institutions" CASCADE;');

    // 2. Drop conflicting ENUM types
    console.log('🗑️ Dropping ENUM types...');
    await sequelize.query('DROP TYPE IF EXISTS "enum_users_role" CASCADE;');
    await sequelize.query('DROP TYPE IF EXISTS "user_role" CASCADE;');
    await sequelize.query('DROP TYPE IF EXISTS "enum_enterprises_sector" CASCADE;');
    
    // Explicitly drop ANY type that might be namespaced or old
    await sequelize.query('DO $$ BEGIN IF EXISTS (SELECT 1 FROM pg_type WHERE typname = \'enum_users_role\') THEN DROP TYPE "enum_users_role" CASCADE; END IF; END $$;');

    console.log('✅ Database Purged.');
    console.log('🔄 Re-syncing models...');
    
    // This will recreate everything correctly
    await sequelize.sync({ force: true });
    
    console.log('✨ Database Schema Rebuilt from Scratch.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Hard Reset Failed:', err);
    process.exit(1);
  }
}

hardReset();
