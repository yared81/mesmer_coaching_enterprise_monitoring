const { sequelize } = require('../src/config/database');
const { Institution, User, Enterprise } = require('../src/models');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const seed = async () => {
  try {
    // 1. Sync Database (Force true to reset during dev if needed, but be careful)
    await sequelize.sync({ force: false });
    console.log('🌱 Database Synced');

    // 2. Create Default Institution
    let institution = await Institution.findOne({ where: { name: 'MESMER HQ' } });
    if (!institution) {
      institution = await Institution.create({
        name: 'MESMER HQ',
        region: 'Addis Ababa',
        contact_email: 'hq@mesmer.com'
      });
      console.log('🏢 Institution Created');
    }

    // 3. Create Admin User
    const adminEmail = 'admin@mesmer.com';
    let admin = await User.findOne({ where: { email: adminEmail } });

    if (!admin) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      admin = await User.create({
        email: adminEmail,
        password_hash: hashedPassword,
        name: 'System Admin',
        role: 'admin',
        institution_id: institution.id,
        is_active: true
      });
      console.log('👤 Admin User Created (admin@mesmer.com / 123456)');
    }

    // 4. Create Supervisor User
    const supervisorEmail = 'supervisor@mesmer.com';
    let supervisor = await User.findOne({ where: { email: supervisorEmail } });
    if (!supervisor) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      supervisor = await User.create({
        email: supervisorEmail,
        password_hash: hashedPassword,
        name: 'Sara Supervisor',
        role: 'supervisor',
        institution_id: institution.id,
        is_active: true
      });
      console.log('👤 Supervisor Created (supervisor@mesmer.com / 123456)');
    }

    // 5. Create Coach User
    const coachEmail = 'coach@mesmer.com';
    let coach = await User.findOne({ where: { email: coachEmail } });

    if (!coach) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      coach = await User.create({
        email: coachEmail,
        password_hash: hashedPassword,
        name: 'Marta Coach',
        role: 'coach',
        institution_id: institution.id,
        is_active: true
      });
      console.log('👤 Coach User Created (coach@mesmer.com / 123456)');
    }

    console.log('✅ Seeding Completed Successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding Failed:', error);
    process.exit(1);
  }
};

seed();
