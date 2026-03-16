const { Enterprise, CoachingSession, DiagnosisReport, DiagnosisResponse, DiagnosisQuestion, DiagnosisCategory } = require('../models');
const { Op } = require('sequelize');

class EnterpriseDashboardService {
  /**
   * Get dashboard stats for a specific enterprise user
   */
  async getEnterpriseStats(userId) {
    // 1. Find the enterprise associated with this user
    const enterprise = await Enterprise.findOne({
      where: { user_id: userId }
    });

    if (!enterprise) {
      throw new Error('Enterprise profile not found for this user');
    }

    // 2. Get latest diagnosis report for radar chart
    const latestReport = await DiagnosisReport.findOne({
      include: [
        {
          model: CoachingSession,
          as: 'session',
          where: { enterprise_id: enterprise.id },
          required: true
        }
      ],
      order: [['created_at', 'DESC']]
    });

    let scores = [];
    if (latestReport) {
      // Fetch category scores (we calculate these from responses if not pre-cached in report)
      // For the hackathon, we can use the average_score from categories if available
      // or derive from responses.
      // Assuming Category Scores are what we want for the Radar Chart.
      
      const responses = await DiagnosisResponse.findAll({
        where: { report_id: latestReport.id },
        include: [
          {
            model: DiagnosisQuestion,
            as: 'question',
            include: [{ model: DiagnosisCategory, as: 'category' }]
          }
        ]
      });

      // Group by category and average
      const categoryMap = {};
      responses.forEach(res => {
        const cat = res.question.category.name;
        if (!categoryMap[cat]) categoryMap[cat] = { total: 0, count: 0 };
        categoryMap[cat].total += parseFloat(res.score || 0);
        categoryMap[cat].count += 1;
      });

      scores = Object.keys(categoryMap).map(name => ({
        name,
        value: categoryMap[name].total / categoryMap[name].count
      }));
    }

    // 3. Get latest session for recommendations
    const latestSession = await CoachingSession.findOne({
      where: { 
        enterprise_id: enterprise.id,
        status: 'completed'
      },
      order: [['scheduled_date', 'DESC']]
    });

    // 4. Counts
    const sessionCount = await CoachingSession.count({
      where: { enterprise_id: enterprise.id }
    });

    return {
      enterprise: {
        id: enterprise.id,
        businessName: enterprise.business_name,
        sector: enterprise.sector
      },
      radarScores: scores,
      latestRecommendation: latestSession ? latestSession.recommendations : 'No recommendations yet.',
      totalSessions: sessionCount,
      lastSessionDate: latestSession ? latestSession.scheduled_date : null
    };
  }
}

module.exports = new EnterpriseDashboardService();
