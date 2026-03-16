const { sequelize } = require('../src/config/database');

async function checkEnums() {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    const [results] = await sequelize.query(`
      SELECT n.nspname as schema, t.typname as name, array_agg(e.enumlabel ORDER BY e.enumsortorder) as values
      FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
      WHERE n.nspname = 'public'
      GROUP BY n.nspname, t.typname;
    `);

    console.log('--- Current Enums in DB ---');
    console.table(results);

    const [columns] = await sequelize.query(`
      SELECT table_name, column_name, udt_name as data_type
      FROM information_schema.columns
      WHERE table_schema = 'public' AND data_type = 'USER-DEFINED';
    `);

    console.log('--- Columns with Custom Types ---');
    console.table(columns);

    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

checkEnums();
