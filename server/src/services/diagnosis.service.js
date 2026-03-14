const { DiagnosisTemplate, DiagnosisCategory, DiagnosisQuestion, DiagnosisChoice, DiagnosisReport, DiagnosisResponse, sequelize } = require('../models');

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
   * Get a specific template by ID with all nested data
   */
  async getTemplateById(id, institutionId) {
    return await DiagnosisTemplate.findOne({
      where: { id, institution_id: institutionId },
      include: [
        {
          model: DiagnosisCategory,
          as: 'categories',
          include: [{ model: DiagnosisQuestion, as: 'questions', include: [{ model: DiagnosisChoice, as: 'choices' }] }]
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
      include: [
        {
          model: DiagnosisCategory,
          as: 'categories',
          include: [{ model: DiagnosisQuestion, as: 'questions', include: [{ model: DiagnosisChoice, as: 'choices' }] }]
        }
      ],
      order: [
        ['version', 'DESC'],
        [{ model: DiagnosisCategory, as: 'categories' }, 'sort_order', 'ASC'],
        [{ model: DiagnosisCategory, as: 'categories' }, { model: DiagnosisQuestion, as: 'questions' }, 'sort_order', 'ASC']
      ]
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

  /**
   * Update an existing template in place (removing versioning)
   */
  async updateTemplate(id, data, institutionId) {
    const transaction = await sequelize.transaction();
    try {
      const template = await DiagnosisTemplate.findOne({
        where: { id, institution_id: institutionId },
        transaction
      });

      if (!template) throw new Error('Assessment Profile not found');

      // Update title if provided
      if (data.title) {
        await template.update({ title: data.title }, { transaction });
      }

      // Completely replace categories, questions, and choices
      if (data.categories) {
        // Fetch existing categories to delete them one by one to trigger cascades if set up, 
        // or just delete the questions/choices explicitly
        const oldCategories = await DiagnosisCategory.findAll({ where: { template_id: template.id }, transaction });
        for (const cat of oldCategories) {
          const oldQuestions = await DiagnosisQuestion.findAll({ where: { category_id: cat.id }, transaction });
          for (const q of oldQuestions) {
            // Manually delete responses associated with this question to satisfy FK constraints 
            // especially if DB level CASCADE hasn't synced yet.
            await DiagnosisResponse.destroy({ where: { question_id: q.id }, transaction });
            await DiagnosisChoice.destroy({ where: { question_id: q.id }, transaction });
            await q.destroy({ transaction });
          }
          await cat.destroy({ transaction });
        }

        for (const catData of data.categories) {
          const category = await DiagnosisCategory.create({
            template_id: template.id,
            name: catData.name,
            sort_order: catData.sort_order
          }, { transaction });

          if (catData.questions) {
            for (const qData of catData.questions) {
              const question = await DiagnosisQuestion.create({
                category_id: category.id,
                text: qData.text,
                sort_order: qData.sort_order
              }, { transaction });

              if (qData.choices) {
                for (const choiceData of qData.choices) {
                  await DiagnosisChoice.create({
                    question_id: question.id,
                    text: choiceData.text,
                    points: choiceData.points,
                    sort_order: choiceData.sort_order
                  }, { transaction });
                }
              }
            }
          }
        }
      }

      await transaction.commit();
      
      // Return reloaded specific template
      return await this.getTemplateById(id, institutionId);
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }
  /**
   * Delete a template
   */
  async deleteTemplate(id, institutionId) {
    const template = await DiagnosisTemplate.findOne({
      where: { id, institution_id: institutionId }
    });

    if (!template) throw new Error('Assessment Profile not found');

    // Delete the template (cascade will handle child models if set up, or we handle it if not)
    return await template.destroy();
  }

  /**
   * Submit a diagnosis report
   * @param {Object} data - { session_id, template_id, responses: { questionId: choiceId } }
   */
  async submitReport(data) {
    const { session_id, template_id, responses } = data;
    const categoryScores = {};
    const primaryChallenges = [];

    // 1. Calculate scores
    let totalCategoryAverages = 0;
    let actualCategoryCount = 0;

    // Get all choices in the template to calculate points
    const template = await DiagnosisTemplate.findByPk(template_id, {
      include: [
        {
          model: DiagnosisCategory,
          as: 'categories',
          include: [{ model: DiagnosisQuestion, as: 'questions', include: [{ model: DiagnosisChoice, as: 'choices' }] }]
        }
      ]
    });

    if (!template) throw new Error('Template not found');

    // Calculate category averages
    for (const category of template.categories) {
      let catPointsSum = 0;
      let answeredCount = 0;

      for (const question of category.questions) {
        // Calculate actual score from responses
        const choiceId = responses[question.id];
        if (choiceId) {
          const choice = question.choices.find(c => c.id === choiceId);
          if (choice) {
            catPointsSum += choice.points;
            answeredCount++;
            
            // Challenge Detection Logic: 
            const maxChoicePoints = Math.max(0, ...question.choices.map(c => c.points));
            if (choice.points <= 1 || (maxChoicePoints > 0 && choice.points < maxChoicePoints * 0.3)) {
              primaryChallenges.push({
                question_id: question.id,
                category_name: category.name,
                question_text: question.text,
                selected_choice: choice.text,
                points: choice.points,
                max_points: maxChoicePoints
              });
            }
          }
        }
      }

      const catAverage = answeredCount > 0 ? catPointsSum / answeredCount : 0;

      categoryScores[category.name] = {
        average_score: parseFloat(catAverage.toFixed(2)),
        sum_points: catPointsSum,
        questions_answered: answeredCount,
        percentage: (catAverage / 5) * 100 // Normalize against max value of 5
      };

      if (answeredCount > 0) {
        totalCategoryAverages += catAverage;
        actualCategoryCount++;
      }
    }

    const overallScore = actualCategoryCount > 0 ? parseFloat((totalCategoryAverages / actualCategoryCount).toFixed(2)) : 0;
    const healthPercentage = parseFloat(((overallScore / 5) * 100).toFixed(2));

    // 2. Create the Report
    const report = await DiagnosisReport.create({
      session_id,
      template_id,
      total_score: overallScore, // Now storing the average score (e.g. 3.02)
      max_score: 5,              // Max is always 5 for this scale
      health_percentage: healthPercentage,
      category_scores: categoryScores,
      primary_challenges: primaryChallenges
    });

    // 3. Create individual responses
    for (const [questionId, choiceId] of Object.entries(responses)) {
      await DiagnosisResponse.create({
        report_id: report.id,
        question_id: questionId,
        choice_id: choiceId
      });
    }

    return report;
  }

  /**
   * Get a diagnosis report by session ID
   */
  async getReportBySessionId(sessionId) {
    return await DiagnosisReport.findOne({
      where: { session_id: sessionId },
      include: [
        {
          model: DiagnosisResponse,
          as: 'responses'
        }
      ]
    });
  }
}

module.exports = new DiagnosisService();
