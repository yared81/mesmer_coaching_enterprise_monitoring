const { DiagnosisTemplate, DiagnosisCategory, DiagnosisQuestion, DiagnosisChoice } = require('../models');

class DiagnosisService {
  /**
   * Get the active template for an institution
   */
  async getLatestTemplate(institutionId) {
    return await DiagnosisTemplate.findOne({
      where: { institution_id: institutionId, is_active: true },
      include: [
        {
          model: DiagnosisCategory,
          as: 'categories',
          include: [
            {
              model: DiagnosisQuestion,
              as: 'questions',
              include: [
                {
                  model: DiagnosisChoice,
                  as: 'choices'
                }
              ]
            }
          ]
        }
      ],
      order: [
        [{ model: DiagnosisCategory, as: 'categories' }, 'sort_order', 'ASC'],
        [{ model: DiagnosisCategory, as: 'categories' }, { model: DiagnosisQuestion, as: 'questions' }, 'sort_order', 'ASC'],
        [{ model: DiagnosisCategory, as: 'categories' }, { model: DiagnosisQuestion, as: 'questions' }, { model: DiagnosisChoice, as: 'choices' }, 'sort_order', 'ASC']
      ]
    });
  }

  /**
   * List all templates for an institution
   */
  async listTemplates(institutionId) {
    return await DiagnosisTemplate.findAll({
      where: { institution_id: institutionId },
      order: [['version', 'DESC']]
    });
  }

  /**
   * Create a new template version
   * This involves deep-cloning or creating new structures
   */
  async createTemplate(data, institutionId) {
    // 1. Deactivate current active template
    await DiagnosisTemplate.update(
      { is_active: false },
      { where: { institution_id: institutionId, is_active: true } }
    );

    // 2. Get latest version number
    const latest = await DiagnosisTemplate.findOne({
      where: { institution_id: institutionId },
      order: [['version', 'DESC']]
    });
    const nextVersion = latest ? latest.version + 1 : 1;

    // 3. Create new template
    const template = await DiagnosisTemplate.create({
      title: data.title || `Diagnosis Template v${nextVersion}`,
      version: nextVersion,
      is_active: true,
      institution_id: institutionId
    });

    // 4. Create Categories/Questions/Choices if provided in data
    if (data.categories) {
      for (const catData of data.categories) {
        const category = await DiagnosisCategory.create({
          template_id: template.id,
          name: catData.name,
          sort_order: catData.sort_order
        });

        if (catData.questions) {
          for (const qData of catData.questions) {
            const question = await DiagnosisQuestion.create({
              category_id: category.id,
              text: qData.text,
              sort_order: qData.sort_order
            });

            if (qData.choices) {
              for (const choiceData of qData.choices) {
                await DiagnosisChoice.create({
                  question_id: question.id,
                  text: choiceData.text,
                  points: choiceData.points,
                  sort_order: choiceData.sort_order
                });
              }
            }
          }
        }
      }
    }

    return template;
  }
}

module.exports = new DiagnosisService();
