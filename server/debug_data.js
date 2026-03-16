const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { CoachingSession, DiagnosisReport, Enterprise } = require('./src/models');
const { sequelize } = require('./src/config/database');

async function debugData() {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    const enterprises = await Enterprise.findAll({
      attributes: ['id', 'business_name'],
      limit: 10
    });

    console.log('\nEnterprises:');
    for (const ent of enterprises) {
      const sessionCount = await CoachingSession.count({ where: { enterprise_id: ent.id } });
      const reports = await DiagnosisReport.findAll({
        include: [{
          model: CoachingSession,
          as: 'session',
          where: { enterprise_id: ent.id }
        }]
      });
      console.log(`- ${ent.business_name} (${ent.id}): ${sessionCount} sessions, ${reports.length} reports`);
    }

    const allReports = await DiagnosisReport.count();
    const allSessions = await CoachingSession.count();
    console.log(`\nGlobal Stats: ${allSessions} Total Sessions, ${allReports} Total Reports`);

    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

debugData();
