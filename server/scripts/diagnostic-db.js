const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const { sequelize } = require('../src/config/database');
const { CoachingSession, Enterprise, User, DiagnosisTemplate } = require('../src/models');

async function diagnostic() {
  try {
    console.log('--- 🛡️  Database Diagnostic Started ---');
    console.log('🌍 Environment Check:');
    console.log(`  - DB_HOST: ${process.env.DB_HOST}`);
    console.log(`  - DB_NAME: ${process.env.DB_NAME}`);
    console.log(`  - DB_USER: ${process.env.DB_USER}`);
    console.log(`  - DB_PASSWORD set: ${!!process.env.DB_PASSWORD}`);
    
    // 1. Check Table Columns
    const [results] = await sequelize.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = 'coaching_sessions'
      ORDER BY ordinal_position;
    `);
    
    console.log('\n📊 Table Structure for coaching_sessions:');
    results.forEach(col => {
      console.log(`  - ${col.column_name}: ${col.data_type} (Nullable: ${col.is_nullable}, Default: ${col.column_default})`);
    });

    // 2. Try simple insertion with ONLY required fields according to model
    console.log('\n🧪 Testing session creation...');
    
    // Get valid IDs first
    const ent = await Enterprise.findOne();
    const coach = await User.findOne({ where: { role: 'coach' } }) || await User.findOne();
    const tpl = await DiagnosisTemplate.findOne();

    if (!ent || !coach) {
      console.log('⚠️  Could not find enterprise or coach to test session creation.');
    } else {
      console.log(`Using Enterprise ID: ${ent.id}, Coach ID: ${coach.id}`);
      
      try {
        const testSession = await CoachingSession.create({
          title: 'Diagnostic Test Session',
          enterprise_id: ent.id,
          coach_id: coach.id,
          template_id: tpl ? tpl.id : null,
          status: 'scheduled',
          session_type: 'coaching'
        });
        console.log('✅ Session creation successful! ID:', testSession.id);
        
        // Cleanup
        await testSession.destroy();
        console.log('🗑️  Test session cleaned up.');
      } catch (err) {
        console.error('❌ Session creation FAILED:');
        console.error('Message:', err.message);
        if (err.parent) console.error('Parent Error:', err.parent.message);
        if (err.errors) console.error('Validation Errors:', err.errors.map(e => e.message));
      }
    }

    console.log('\n--- ✅ Diagnostic Finished ---');
    process.exit(0);
  } catch (error) {
    console.error('💥 Diagnostic script crashed:', error.message);
    process.exit(1);
  }
}

diagnostic();
