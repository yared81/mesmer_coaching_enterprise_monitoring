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
  /**
   * Get templates for an institution
   * @param {string} institutionId
   * @param {boolean} isAdmin
   */
  async listTemplates(institutionId, isAdmin = false) {
    const where = isAdmin ? {} : { institution_id: institutionId };
    
    return await DiagnosisTemplate.findAll({
      where,
      include: [
        {
          model: DiagnosisCategory,
          as: 'categories',
          include: [{ model: DiagnosisQuestion, as: 'questions', include: [{ model: DiagnosisChoice, as: 'choices' }] }]
        }
      ],
      order: [
        ['version', 'DESC'],
        ['created_at', 'DESC']
      ]
    });
  }

  /**
   * Create a new template version
   */
  async createTemplate(data, institutionId) {
    return await sequelize.transaction(async (t) => {
      // 1. Deactivate current active template for THIS institution
      await DiagnosisTemplate.update(
        { is_active: false },
        { 
          where: { institution_id: institutionId, is_active: true },
          transaction: t
        }
      );

      // 2. Get latest version number for THIS institution
      const latest = await DiagnosisTemplate.findOne({
        where: { institution_id: institutionId },
        order: [['version', 'DESC']],
        transaction: t
      });
      const nextVersion = latest ? latest.version + 1 : 1;

      // 3. Create new template
      const template = await DiagnosisTemplate.create({
        title: data.title || `Diagnosis Template v${nextVersion}`,
        version: nextVersion,
        is_active: true,
        institution_id: institutionId
      }, { transaction: t });

      // 4. Create Categories/Questions/Choices
      if (data.categories) {
        for (let cIdx = 0; cIdx < data.categories.length; cIdx++) {
          const catData = data.categories[cIdx];
          const category = await DiagnosisCategory.create({
            template_id: template.id,
            name: catData.name,
            sort_order: catData.sort_order || cIdx
          }, { transaction: t });

          if (catData.questions) {
            for (let qIdx = 0; qIdx < catData.questions.length; qIdx++) {
              const qData = catData.questions[qIdx];
              const question = await DiagnosisQuestion.create({
                category_id: category.id,
                text: qData.text,
                sort_order: qData.sort_order || qIdx
              }, { transaction: t });

              if (qData.choices) {
                for (let chIdx = 0; chIdx < qData.choices.length; chIdx++) {
                  const choiceData = qData.choices[chIdx];
                  await DiagnosisChoice.create({
                    question_id: question.id,
                    text: choiceData.text,
                    points: choiceData.points,
                    sort_order: choiceData.sort_order || chIdx
                  }, { transaction: t });
                }
              }
            }
          }
        }
      }

      return template;
    });
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

      // 1. Update title if provided
      if (data.title) {
        await template.update({ title: data.title }, { transaction });
      }

      if (data.categories) {
        const incomingCatIds = data.categories.filter(c => c.id).map(c => c.id);
        
        // 2. Delete Categories not in the incoming data
        const oldCategories = await DiagnosisCategory.findAll({ where: { template_id: template.id }, transaction });
        for (const oldCat of oldCategories) {
          if (!incomingCatIds.includes(oldCat.id)) {
            // Delete questions and choices for this category (CASCADE handles responses if linked to Questions)
            const oldQuestions = await DiagnosisQuestion.findAll({ where: { category_id: oldCat.id }, transaction });
            for (const q of oldQuestions) {
              await DiagnosisResponse.destroy({ where: { question_id: q.id }, transaction });
              await DiagnosisChoice.destroy({ where: { question_id: q.id }, transaction });
              await q.destroy({ transaction });
            }
            await oldCat.destroy({ transaction });
          }
        }

        // 3. Sync Categories
        for (const catData of data.categories) {
          let category;
          if (catData.id) {
            category = await DiagnosisCategory.findByPk(catData.id, { transaction });
            if (category) {
              await category.update({ 
                name: catData.name, 
                sort_order: catData.sort_order 
              }, { transaction });
            }
          }

          if (!category) {
            category = await DiagnosisCategory.create({
              template_id: template.id,
              name: catData.name,
              sort_order: catData.sort_order
            }, { transaction });
          }

          // 4. Sync Questions within the Category
          if (catData.questions) {
            const incomingQIds = catData.questions.filter(q => q.id).map(q => q.id);
            const oldQuestions = await DiagnosisQuestion.findAll({ where: { category_id: category.id }, transaction });
            
            // Delete removed questions
            for (const oldQ of oldQuestions) {
              if (!incomingQIds.includes(oldQ.id)) {
                await DiagnosisResponse.destroy({ where: { question_id: oldQ.id }, transaction });
                await DiagnosisChoice.destroy({ where: { question_id: oldQ.id }, transaction });
                await oldQ.destroy({ transaction });
              }
            }

            for (const qData of catData.questions) {
              let question;
              if (qData.id) {
                question = await DiagnosisQuestion.findByPk(qData.id, { transaction });
                if (question) {
                  await question.update({
                    text: qData.text,
                    sort_order: qData.sort_order
                  }, { transaction });
                }
              }

              if (!question) {
                question = await DiagnosisQuestion.create({
                  category_id: category.id,
                  text: qData.text,
                  sort_order: qData.sort_order
                }, { transaction });
              }

              // 5. Sync Choices (Choice Reconciliation)
              // We try to match incoming choices with existing ones to preserve IDs
              if (qData.choices) {
                const existingChoices = await DiagnosisChoice.findAll({ 
                  where: { question_id: question.id }, 
                  transaction 
                });
                
                const usedChoiceIds = [];
                for (const choiceData of qData.choices) {
                  // Try to find a matching existing choice
                  const match = existingChoices.find(ec => 
                    !usedChoiceIds.includes(ec.id) && 
                    ec.text === choiceData.text && 
                    ec.points === choiceData.points
                  );

                  if (match) {
                    await match.update({ sort_order: choiceData.sort_order }, { transaction });
                    usedChoiceIds.push(match.id);
                  } else {
                    const newChoice = await DiagnosisChoice.create({
                      question_id: question.id,
                      text: choiceData.text,
                      points: choiceData.points,
                      sort_order: choiceData.sort_order
                    }, { transaction });
                    usedChoiceIds.push(newChoice.id);
                  }
                }

                // Delete old choices that weren't matched
                for (const ec of existingChoices) {
                  if (!usedChoiceIds.includes(ec.id)) {
                    // Note: If we delete a choice, responses using it will break. 
                    // But if text/points changed, the response is arguably invalid anyway.
                    await ec.destroy({ transaction });
                  }
                }
              }
            }
          }
        }
      }

      await transaction.commit();
      return await this.getTemplateById(id, institutionId);
    } catch (error) {
      if (transaction) await transaction.rollback();
      console.error('Granular Update Failed:', error);
      throw error;
    }
  }

  /**
   * Delete a template and all its dependencies
   */
  async deleteTemplate(id, institutionId) {
    return await sequelize.transaction(async (t) => {
      const template = await DiagnosisTemplate.findOne({
        where: { id, institution_id: institutionId },
        transaction: t
      });

      if (!template) throw new Error('Template not found or unauthorized');

      // Delete the template (cascade will handle child models if set up, or we handle it if not)
      await template.destroy({ transaction: t });
      return true;
    });
  }

  /**
   * Submit a diagnosis report (typically from a Coach)
   * @param {Object} data - { session_id, template_id, responses: { questionId: choiceId } }
   */
  async submitReport(data) {
    const { session_id, template_id, responses } = data;
    
    return await sequelize.transaction(async (t) => {
      const categoryScores = {};
      const primaryChallenges = [];

      // 1. Fetch Template
      const template = await DiagnosisTemplate.findByPk(template_id, {
        include: [
          {
            model: DiagnosisCategory,
            as: 'categories',
            include: [{ model: DiagnosisQuestion, as: 'questions', include: [{ model: DiagnosisChoice, as: 'choices' }] }]
          }
        ],
        transaction: t
      });

      if (!template) throw new Error('Template not found');

      // 2. Filter responses to only those that exist in the current template
      const allTemplateQuestionIds = new Set();
      template.categories.forEach(cat => {
        cat.questions.forEach(q => allTemplateQuestionIds.add(q.id));
      });

      const finalResponses = {};
      let mismatchCount = 0;
      for (const qId of Object.keys(responses)) {
        if (allTemplateQuestionIds.has(qId)) {
          finalResponses[qId] = responses[qId];
        } else {
          mismatchCount++;
        }
      }

      // Conflict detection
      if (mismatchCount > Object.keys(responses).length * 0.5 && Object.keys(responses).length > 0) {
        const error = new Error('The assessment structure has significantly changed. Please refresh and try again.');
        error.status = 409;
        throw error;
      }

      // 3. Calculate scores
      let totalCategoryAverages = 0;
      let actualCategoryCount = 0;

      for (const category of template.categories) {
        let catPointsSum = 0;
        let answeredCount = 0;

        for (const question of category.questions) {
          const choiceId = finalResponses[question.id];
          if (choiceId) {
            const choice = question.choices.find(c => c.id === choiceId);
            if (choice) {
              catPointsSum += choice.points;
              answeredCount++;
              
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
          percentage: (catAverage / 5) * 100
        };

        if (answeredCount > 0) {
          totalCategoryAverages += catAverage;
          actualCategoryCount++;
        }
      }

      const overallScore = actualCategoryCount > 0 ? parseFloat((totalCategoryAverages / actualCategoryCount).toFixed(2)) : 0;
      const healthPercentage = parseFloat(((overallScore / 5) * 100).toFixed(2));

      // 4. Create the Report (Atomic)
      const report = await DiagnosisReport.create({
        session_id,
        template_id,
        total_score: overallScore,
        max_score: 5,
        health_percentage: healthPercentage,
        category_scores: categoryScores,
        primary_challenges: primaryChallenges
      }, { transaction: t });

      // 5. Create individual responses
      for (const [questionId, choiceId] of Object.entries(finalResponses)) {
        await DiagnosisResponse.create({
          report_id: report.id,
          question_id: questionId,
          choice_id: choiceId
        }, { transaction: t });
      }

      return report;
    });
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
