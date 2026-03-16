const { sequelize } = require('../src/config/database');

async function fixTypos() {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    const queryInterface = sequelize.getQueryInterface();

    // 1. Check notifications table
    const notifTable = await queryInterface.describeTable('notifications');
    if (notifTable.instituion_id) {
      console.log('Fixing typo instituion_id in notifications table...');
      await queryInterface.renameColumn('notifications', 'instituion_id', 'institution_id');
    }

    // 2. Check users table
    const usersTable = await queryInterface.describeTable('users');
    if (usersTable.instustion_id) {
      console.log('Fixing typo instustion_id in users table...');
      await queryInterface.renameColumn('users', 'instustion_id', 'institution_id');
    }

    // 3. Just in case, try to add institution_id if it's missing but we expect it
    if (!notifTable.institution_id && !notifTable.instituion_id) {
        console.log('Adding institution_id to notifications table...');
        await queryInterface.addColumn('notifications', 'institution_id', {
            type: require('sequelize').DataTypes.UUID,
            allowNull: true,
            references: {
                model: 'institutions',
                key: 'id'
            }
        });
    }

    console.log('✅ Cleanup complete or no typos found.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error during cleanup:', err);
    process.exit(1);
  }
}

fixTypos();
