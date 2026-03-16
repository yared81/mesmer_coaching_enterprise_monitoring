const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { CoachingSession, DiagnosisReport, Enterprise } = require('./src/models');

async function debugAll() {
  try {
    const enterprises = await Enterprise.findAll();
    console.log(`Checking ${enterprises.length} enterprises...\n`);

    for (const ent of enterprises) {
      const sessionCount = await CoachingSession.count({ where: { enterprise_id: ent.id } });
      const reportCount = await DiagnosisReport.count({
        include: [{
          model: CoachingSession,
          as: 'session',
          where: { enterprise_id: ent.id }
        }]
      });

      if (sessionCount > 0) {
        console.log(`${ent.business_name}: ${sessionCount} sessions, ${reportCount} reports`);
      }
    }
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

debugAll();
