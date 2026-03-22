const { sequelize } = require('../src/config/database');
const { User, Institution, Enterprise } = require('../src/models');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Force sync (CAUTION: deletes data!)
    await sequelize.sync({ force: true });
    console.log('Database synced (all tables cleared).');

    // 1. Create Default Institution
    const inst = await Institution.create({
      name: 'Mesmer Enterprise Monitoring',
      address: 'Addis Ababa, Ethiopia',
      contact_person: 'Main Admin',
      contact_email: 'office@mesmer.com',
      contact_phone: '+251911000000',
      is_active: true
    });
    console.log('✅ Institution created.');

    const passwordHash = await bcrypt.hash('password123', 10);

    // 2. Create Official 11 Roles
    const usersToCreate = [
      { name: 'Root Admin', role: 'super_admin', email: 'superadmin@mesmer.com' },
      { name: 'Program Manager', role: 'program_manager', email: 'programmanager@mesmer.com' },
      { name: 'Regional Coordinator', role: 'regional_coordinator', email: 'regionalcoordinator@mesmer.com' },
      { name: 'M&E Officer', role: 'me_officer', email: 'meofficer@mesmer.com' },
      { name: 'Data Auditor', role: 'data_verifier', email: 'dataverifier@mesmer.com' },
      { name: 'Master Trainer', role: 'trainer', email: 'trainer@mesmer.com' },
      { name: 'Assigned Coach', role: 'coach', email: 'coach@mesmer.com' },
      { name: 'Field Enumerator', role: 'enumerator', email: 'enumerator@mesmer.com' },
      { name: 'Communications Manager', role: 'comms_officer', email: 'commsofficer@mesmer.com' },
      { name: 'External Stakeholder', role: 'stakeholder', email: 'stakeholder@mesmer.com' },
    ];

    for (const u of usersToCreate) {
      await User.create({
        ...u,
        password_hash: passwordHash,
        institution_id: inst.id,
        is_active: true,
        phone: '+2510000000'
      });
    }
    console.log('✅ 10 Management/Support roles created.');

    // 3. Create Sample Enterprise & Beneficiary User (11th Role)
    const coach = await User.findOne({ where: { role: 'coach' } });
    
    const enterprise = await Enterprise.create({
      business_name: 'Enat Food Complex',
      owner_name: 'Enat',
      sector: 'manufacturing',
      employee_count: 15,
      location: 'Bole, Addis Ababa',
      phone: '+251911223344',
      email: 'enat@example.com',
      coach_id: coach.id,
      institution_id: inst.id,
      status: 'active'
    });

    await User.create({
      name: 'Enat (Owner)',
      email: 'beneficiary@mesmer.com',
      password_hash: passwordHash,
      role: 'enterprise_user',
      institution_id: inst.id,
      phone: '+251911223344',
      is_active: true
    });
    
    // Link enterprise to user
    const enterpriseUser = await User.findOne({ where: { role: 'enterprise_user' } });
    await enterprise.update({ user_id: enterpriseUser.id });

    console.log('✅ Sample Enterprise & Beneficiary created.');
    console.log('\n--- SEEDING COMPLETE (Strict 11 Roles) ---');
    console.log('All passwords: password123');
    console.log('Super Admin: superadmin@mesmer.com');
    console.log('Program Manager: programmanager@mesmer.com');
    console.log('Regional Coordinator: regionalcoordinator@mesmer.com');
    console.log('Beneficiary: beneficiary@mesmer.com');

  } catch (error) {
    console.error('Seeding failed:', error);
  } finally {
    process.exit();
  }
}

seed();
