const { DiagnosisTemplate, DiagnosisCategory, DiagnosisQuestion, DiagnosisChoice, DiagnosisReport, DiagnosisResponse } = require('../models');

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

  /**
   * Submit a diagnosis report
   * @param {Object} data - { session_id, template_id, responses: { questionId: choiceId } }
   */
  async submitReport(data) {
    const { session_id, template_id, responses } = data;
    const categoryScores = {};
    const primaryChallenges = [];

    // 1. Calculate scores
    let totalScore = 0;
    let maxPossibleScore = 0;

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

    // Calculate max possible score and category scores
    for (const category of template.categories) {
      let catScore = 0;
      let catMax = 0;

      for (const question of category.questions) {
        const maxChoicePoints = Math.max(...question.choices.map(c => c.points));
        catMax += maxChoicePoints;

        // Calculate actual score from responses
        const choiceId = responses[question.id];
        if (choiceId) {
          const choice = question.choices.find(c => c.id === choiceId);
          if (choice) {
            catScore += choice.points;
            
            // Challenge Detection Logic: 
            // points <= 1 OR < 30% of max
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

      categoryScores[category.name] = {
        score: catScore,
        max: catMax,
        percentage: catMax > 0 ? (catScore / catMax) * 100 : 0
      };

      totalScore += catScore;
      maxPossibleScore += catMax;
    }

    const healthPercentage = maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0;

    // 2. Create the Report
    const report = await DiagnosisReport.create({
      session_id,
      template_id,
      total_score: totalScore,
      max_score: maxPossibleScore,
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
