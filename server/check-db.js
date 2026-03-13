const path = require('path');
require('dotenv').config({ path: path.join(__dirname, './.env') });
const { sequelize } = require('./src/config/database');

async function checkSchema() {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    const [results] = await sequelize.query(`
      SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'
    `);

    console.log('Tables in public schema:');
    results.forEach(row => {
      console.log(`- ${row.table_name}`);
    });

    process.exit(0);
  } catch (err) {
    console.error('Check failed:', err);
    process.exit(1);
  }
}

checkSchema();
