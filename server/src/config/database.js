const { Sequelize } = require('sequelize');
console.log('--- DATABASE CONFIG LOADED ---');
require('dotenv').config();

const isSqlite = (process.env.DB_DIALECT || 'postgres') === 'sqlite';

const sequelize = isSqlite 
  ? new Sequelize({
      dialect: 'sqlite',
      storage: process.env.DB_STORAGE || './data/mesmer.sqlite',
      logging: process.env.NODE_ENV === 'development' ? console.log : false,
      define: {
        timestamps: true,
        underscored: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at'
      }
    })
  : new Sequelize(
      process.env.DB_NAME,
      process.env.DB_USER,
      process.env.DB_PASSWORD,
      {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        logging: process.env.NODE_ENV === 'development' ? console.log : false,
        pool: {
          max: 5,
          min: 0,
          acquire: 30000,
          idle: 10000
        },
        define: {
          timestamps: true,
          underscored: true,
          createdAt: 'created_at',
          updatedAt: 'updated_at'
        }
      }
    );

const connectDB = async () => {
  try {
    if (isSqlite) {
      const fs = require('fs');
      const path = require('path');
      const storagePath = process.env.DB_STORAGE || './data/mesmer.sqlite';
      const dir = path.dirname(storagePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
        console.log(`📁 Created database directory: ${dir}`);
      }
    }

    await sequelize.authenticate();
    console.log(`✅ ${isSqlite ? 'SQLite' : 'PostgreSQL'} Connected via Sequelize`);
    
    if (!isSqlite) {
      // Fix for enum conflict: cast error between session_status and enum_coaching_sessions_status
      try {
        const [statusCols] = await sequelize.query(`SELECT udt_name FROM information_schema.columns WHERE table_name = 'coaching_sessions' AND column_name = 'status'`);
        if (statusCols.length > 0 && statusCols[0].udt_name !== 'enum_coaching_sessions_status') {
          await sequelize.query('ALTER TABLE coaching_sessions ALTER COLUMN status DROP DEFAULT');
          await sequelize.query('ALTER TABLE coaching_sessions RENAME COLUMN status TO status_old');
        }

        const [typeCols] = await sequelize.query(`SELECT udt_name FROM information_schema.columns WHERE table_name = 'coaching_sessions' AND column_name = 'session_type'`);
        if (typeCols.length > 0 && typeCols[0].udt_name !== 'enum_coaching_sessions_session_type') {
          await sequelize.query('ALTER TABLE coaching_sessions ALTER COLUMN session_type DROP DEFAULT');
          await sequelize.query('ALTER TABLE coaching_sessions RENAME COLUMN session_type TO session_type_old');
        }
      } catch (e) {
        // Quietly handle migration info
      }
    }

    // Sync models (Safe sync with alter to handle new columns)
    await sequelize.sync({ alter: true });
    console.log('🔄 Database Schema Synchronized (Alter Mode)');
  } catch (error) {
    console.error('❌ Database Initialization Failed:', error.message);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
