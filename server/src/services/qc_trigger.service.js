const { QcAudit, CoachingSession } = require('../models');

class QcTriggerService {
  /**
   * Process and potentially trigger a QC audit for a new enterprise (Baseline)
   */
  async processBaseline(enterprise) {
    const randomChance = 0.15; // 15% Statistical Sample
    
    if (Math.random() < randomChance) {
      return await QcAudit.create({
        target_type: 'baseline',
        target_id: enterprise.id,
        is_random_sample: true,
        flag_reason: 'Random Statistical Sample (15%)',
        status: 'pending'
      });
    }
    return null;
  }

  /**
   * Process and potentially trigger a QC audit for a new/completed session
   */
  async processSession(session) {
    const randomChance = 0.10; // 10% Statistical Sample
    let flagReason = null;
    let isRandomSample = false;

    // 1. Check for Outlier Performance (Revenue jump > 100%)
    if (session.revenue_growth_percent > 100) {
      flagReason = `Anomalous Growth detected: ${session.revenue_growth_percent}% revenue jump.`;
    }

    // 2. Check for Onboarding Verification (First 3 sessions of any coach)
    if (!flagReason) {
      const coachSessionCount = await CoachingSession.count({
        where: { coach_id: session.coach_id, status: 'completed' }
      });
      if (coachSessionCount <= 3) {
        flagReason = `Quality Onboarding: Coach is in first 3 completed sessions (${coachSessionCount}/3).`;
      }
    }

    // 3. Natural Random Sample if no specific risk flag
    if (!flagReason && Math.random() < randomChance) {
      flagReason = 'Random Statistical Sample (10%)';
      isRandomSample = true;
    }

    if (flagReason) {
      return await QcAudit.create({
        target_type: 'session',
        target_id: session.id,
        is_random_sample: isRandomSample,
        flag_reason: flagReason,
        status: 'pending'
      });
    }
    
    return null;
  }
}

module.exports = new QcTriggerService();
