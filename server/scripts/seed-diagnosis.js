const { sequelize } = require('../src/config/database');
const { Institution, DiagnosisTemplate, DiagnosisCategory, DiagnosisQuestion, DiagnosisChoice } = require('../src/models');
require('dotenv').config();

const questions = {
  "Finance": [
    "Does the business keep daily sales records?",
    "Are business and personal finances separated?",
    "Does the business have a bank account?",
    "Does the business track expenses?",
    "Does the business have outstanding loans?",
    "Is the business able to save money monthly?"
  ],
  "Marketing": [
    "Does the business have a marketing strategy?",
    "Does the business use social media?",
    "How does the business attract new customers?",
    "Does the business track customer feedback?",
    "Does the business have pricing strategy?"
  ],
  "Operations": [
    "Does the business have reliable suppliers?",
    "Does the business track inventory?",
    "Is equipment well-maintained?",
    "Does the business have enough space?",
    "Are operating hours consistent?",
    "Does the business have delivery system?"
  ],
  "Management": [
    "Does the owner have a business plan?",
    "Are employees trained properly?",
    "Does the owner keep personal and business time separate?",
    "Does the business have growth plans?"
  ]
};

const choices = [
  { text: "Yes, consistently (daily records kept)", points: 10 },
  { text: "Yes, but not every day", points: 5 },
  { text: "No, no records kept", points: 0 },
  { text: "I don't know / Not observed", points: 0 }
];

// Note: Using slightly different choices for different question types if needed, 
// but for this seed we follow the provided standard.

const seedDiagnosis = async () => {
  try {
    await sequelize.sync({ force: false });
    console.log('🌱 Database Synced');

    const institution = await Institution.findOne({ where: { name: 'MESMER HQ' } });
    if (!institution) {
      console.error('❌ MESMER HQ institution not found. Please run seed.js first.');
      process.exit(1);
    }

    // Deactivate old templates
    await DiagnosisTemplate.update({ is_active: false }, { where: { institution_id: institution.id } });

    const template = await DiagnosisTemplate.create({
      title: 'MESMER Standard Business Assessment v1',
      version: 1,
      is_active: true,
      institution_id: institution.id
    });
    console.log('📋 Template Created');

    let categoryOrder = 0;
    for (const [catName, qList] of Object.entries(questions)) {
      const category = await DiagnosisCategory.create({
        template_id: template.id,
        name: catName,
        sort_order: categoryOrder++
      });
      console.log(`  📁 Category: ${catName}`);

      let questionOrder = 0;
      for (const qText of qList) {
        const question = await DiagnosisQuestion.create({
          category_id: category.id,
          text: qText,
          sort_order: questionOrder++
        });

        let choiceOrder = 0;
        for (const c of choices) {
          // Adjust labels for generic choices if they don't fit the question perfectly, 
          // but following the user's specific text for the first one as a pattern.
          let label = c.text;
          if (label.includes("daily records kept") && !qText.includes("records")) {
            label = label.split(" (")[0]; // Use "Yes, consistently"
          }

          await DiagnosisChoice.create({
            question_id: question.id,
            text: label,
            points: c.points,
            sort_order: choiceOrder++
          });
        }
      }
    }

    console.log('✅ Diagnosis Seeding Completed Successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding Failed:', error);
    process.exit(1);
  }
};

seedDiagnosis();
