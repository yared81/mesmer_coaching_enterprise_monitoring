const { sequelize, DiagnosisTemplate, DiagnosisCategory, DiagnosisQuestion, DiagnosisChoice, Institution } = require('../src/models');

async function seedAssessment() {
  const transaction = await sequelize.transaction();
  try {
    const institutions = await Institution.findAll({ transaction });
    if (institutions.length === 0) {
      console.error('❌ No Institutions found. Please login or create one first.');
      return;
    }

    console.log(`🌱 Seeding Enterprise Assessment for ${institutions.length} institutions...`);

    for (const inst of institutions) {
      console.log(`  - Seeding for: ${inst.name}`);

      // 1. Create or find the Template
      const [template] = await DiagnosisTemplate.findOrCreate({
        where: { title: 'Enterprise Assessment Form', institution_id: inst.id },
        defaults: { description: 'Official Enterprise Assessment Tool (Mixed Format)' },
        transaction
      });

      // 2. Clear existing structure (Clean start)
      const oldCats = await DiagnosisCategory.findAll({ where: { template_id: template.id }, transaction });
      for (const cat of oldCats) {
        const qs = await DiagnosisQuestion.findAll({ where: { category_id: cat.id }, transaction });
        for (const q of qs) {
          await DiagnosisChoice.destroy({ where: { question_id: q.id }, transaction });
          await q.destroy({ transaction });
        }
        await cat.destroy({ transaction });
      }

      const assessmentData = [
        {
          name: '1. Management & Leadership',
          questions: [
            { text: 'The enterprise has clear business goals.', type: 'scale' },
            { text: 'The owner demonstrates strong decision-making ability.', type: 'scale' },
            { text: 'Business records are properly maintained.', type: 'scale' },
            { text: 'Roles and responsibilities are clearly defined.', type: 'scale' },
            { text: 'Does the enterprise have a written business plan?', type: 'boolean' }
          ]
        },
        {
          name: '2. Financial Management',
          questions: [
            { text: 'The enterprise understands its profit and loss clearly.', type: 'scale' },
            { text: 'Cash flow is managed effectively.', type: 'scale' },
            { text: 'Financial records are accurate and organized.', type: 'scale' },
            { text: 'Does the enterprise separate business money from personal money?', type: 'boolean' },
            { text: 'Does the business track income and expenses regularly?', type: 'boolean' }
          ]
        },
        {
          name: '3. Operations & Productivity',
          questions: [
            { text: 'Work processes are organized and efficient.', type: 'scale' },
            { text: 'Products or services are delivered on time.', type: 'scale' },
            { text: 'Equipment and tools are used effectively.', type: 'scale' },
            { text: 'Is inventory or stock properly managed?', type: 'boolean' },
            { text: 'Is product or service quality consistently maintained?', type: 'boolean' }
          ]
        },
        {
          name: '4. Marketing & Sales',
          questions: [
            { text: 'The enterprise has a clear understanding of its customers.', type: 'scale' },
            { text: 'The business maintains good customer relationships.', type: 'scale' },
            { text: 'Sales performance is regularly reviewed.', type: 'scale' },
            { text: 'Does the enterprise actively promote its products or services?', type: 'boolean' },
            { text: 'Does the business have a pricing strategy?', type: 'boolean' }
          ]
        },
        {
          name: '5. Innovation & Growth',
          questions: [
            { text: 'The enterprise introduces improvements or new ideas.', type: 'scale' },
            { text: 'The business adapts to market changes.', type: 'scale' },
            { text: 'The enterprise uses technology to improve performance.', type: 'scale' },
            { text: 'Does the enterprise participate in training or capacity-building activities?', type: 'boolean' },
            { text: 'Does the business seek opportunities for expansion?', type: 'boolean' }
          ]
        }
      ];

      for (let cIdx = 0; cIdx < assessmentData.length; cIdx++) {
        const catData = assessmentData[cIdx];
        const category = await DiagnosisCategory.create({
          template_id: template.id,
          name: catData.name,
          sort_order: cIdx
        }, { transaction });

        for (let qIdx = 0; qIdx < catData.questions.length; qIdx++) {
          const qData = catData.questions[qIdx];
          const question = await DiagnosisQuestion.create({
            category_id: category.id,
            text: qData.text,
            sort_order: qIdx
          }, { transaction });

          if (qData.type === 'boolean') {
            await DiagnosisChoice.bulkCreate([
              { question_id: question.id, text: 'Yes', points: 1, sort_order: 1 },
              { question_id: question.id, text: 'No', points: 0, sort_order: 2 }
            ], { transaction });
          } else {
            await DiagnosisChoice.bulkCreate([
              { question_id: question.id, text: '1 - Very Weak', points: 1, sort_order: 1 },
              { question_id: question.id, text: '2 - Weak', points: 2, sort_order: 2 },
              { question_id: question.id, text: '3 - Moderate', points: 3, sort_order: 3 },
              { question_id: question.id, text: '4 - Good', points: 4, sort_order: 4 },
              { question_id: question.id, text: '5 - Excellent', points: 5, sort_order: 5 }
            ], { transaction });
          }
        }
      }
    }

    await transaction.commit();
    console.log('✅ Official Enterprise Assessment Tool seeded for ALL institutions!');
    process.exit(0);
  } catch (error) {
    if (transaction) await transaction.rollback();
    console.error('❌ Seeding Failed:', error);
    process.exit(1);
  }
}

seedAssessment();
