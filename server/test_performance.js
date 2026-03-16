const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const diagnosisService = require('./src/services/diagnosis.service');

async function testPerformance() {
  const enterpriseId = '97f22bbd-2991-4c51-9434-0c478ee063ea'; // Enat Milk Producing
  console.log(`Testing performance for: ${enterpriseId}`);
  
  try {
    const result = await diagnosisService.getEnterprisePerformance(enterpriseId);
    console.log('\nResult:', JSON.stringify(result, null, 2));
    process.exit(0);
  } catch (err) {
    console.error('Test Failed:', err);
    process.exit(1);
  }
}

testPerformance();
