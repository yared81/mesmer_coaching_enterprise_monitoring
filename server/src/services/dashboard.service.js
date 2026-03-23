const { Institution, User, Enterprise, CoachingSession, DiagnosisReport, DiagnosisTemplate, Notification, PhoneFollowupLog, sequelize } = require('../models');
const { Op } = require('sequelize');

class DashboardService {
  /**
   * Get aggregate stats for Admin
   */
  async getAdminStats() {
    const [totalInstitutions, totalCoaches, totalEnterprises, recentEnterprises] = await Promise.all([
      Institution.count(),
      User.count({ where: { role: 'coach' } }),
      Enterprise.count(),
      Enterprise.findAll({
        limit: 5,
        order: [['registered_at', 'DESC']],
        include: [
          { model: User, as: 'coach', attributes: ['name'] },
          { model: Institution, as: 'institution', attributes: ['name'] }
        ]
      })
    ]);

    return {
      stats: {
        totalInstitutions,
        totalCoaches,
        totalEnterprises,
        activePrograms: totalInstitutions // Simplified for now
      },
      recentEnterprises
    };
  }

  /**
   * Get aggregate stats for Supervisor
   */
  async getSupervisorStats(institutionId) {
    const [totalCoaches, totalEnterprises, avgReport, recentActivity] = await Promise.all([
      User.count({ where: { institution_id: institutionId, role: 'coach' } }),
      Enterprise.count({ where: { institution_id: institutionId } }),
      DiagnosisReport.findOne({
        include: [{
          model: DiagnosisTemplate,
          as: 'template',
          where: { institution_id: institutionId },
          attributes: []
        }],
        attributes: [
          [sequelize.fn('AVG', sequelize.col('health_percentage')), 'avgHealth']
        ],
        raw: true
      }),
      Notification.findAll({
        where: { institution_id: institutionId },
        limit: 10,
        order: [['created_at', 'DESC']]
      })
    ]);

    return {
      stats: {
        totalCoaches,
        totalEnterprises,
        avgAssessmentScore: avgReport ? parseFloat(parseFloat(avgReport.avgHealth || 0).toFixed(1)) : 0
      },
      recentActivity
    };
  }

  /**
   * Get aggregate stats for Coach
   */
  async getCoachStats(coachId) {
    const [totalEnterprises, totalSessions, avgReport, recentActivity, recentSessions, recentPhoneLogs] = await Promise.all([
      Enterprise.count({ where: { coach_id: coachId } }),
      CoachingSession.count({ where: { coach_id: coachId } }),
      DiagnosisReport.findOne({
        include: [{
          model: CoachingSession,
          as: 'session',
          where: { coach_id: coachId },
          attributes: []
        }],
        attributes: [
          [sequelize.fn('AVG', sequelize.col('health_percentage')), 'avgHealth']
        ],
        raw: true
      }),
      Notification.findAll({
        where: { user_id: coachId },
        limit: 10,
        order: [['created_at', 'DESC']]
      }),
      CoachingSession.findAll({
        where: { coach_id: coachId },
        limit: 5,
        order: [['scheduled_date', 'DESC']],
        include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
      }),
      PhoneFollowupLog.findAll({
        where: { coach_id: coachId },
        limit: 5,
        order: [['date', 'DESC']],
        include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
      })
    ]);

    // Merge sessions and phone logs into interactions
    const interactions = [
      ...recentSessions.map(s => ({
        id: s.id,
        type: 'session',
        title: s.enterprise?.business_name || 'Session',
        description: s.title,
        timestamp: s.scheduled_date,
        status: s.status
      })),
      ...recentPhoneLogs.map(p => ({
        id: p.id,
        type: 'phone_call',
        title: p.enterprise?.business_name || 'Phone Call',
        description: p.purpose,
        timestamp: p.date
      }))
    ].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 10);

    return {
      stats: {
        totalEnterprises,
        totalSessions,
        pendingTasks: 0, 
        avgAssessmentScore: avgReport ? parseFloat(parseFloat(avgReport.avgHealth || 0).toFixed(1)) : 0
      },
      recentActivity,
      recentInteractions: interactions
    };
  }

  /**
   * Get aggregate stats for M&E / Program Manager
   */
  async getMeStats(institutionId = null) {
    const enterpriseFilter = institutionId ? { institution_id: institutionId } : {};

    const [
      totalActive,
      totalGraduated,
      baselineCount,
      trainingCount,
      coachingCount,
      midlineCount,
      qcPassed,
      qcFailed
    ] = await Promise.all([
      Enterprise.count({ where: { ...enterpriseFilter, status: 'active' } }),
      Enterprise.count({ where: { ...enterpriseFilter, status: 'graduated' } }),
      // Funnel: Baseline (has score)
      Enterprise.count({ where: { ...enterpriseFilter, baseline_score: { [Op.gt]: 0 } } }),
      // Funnel: Training (attended at least one)
      TrainingAttendance.count({ 
        distinct: true, 
        col: 'enterprise_id',
        include: institutionId ? [{ model: Enterprise, as: 'enterprise', where: enterpriseFilter, attributes: [] }] : []
      }),
      // Funnel: Coaching (had at least one session)
      CoachingSession.count({ 
        distinct: true, 
        col: 'enterprise_id',
        include: institutionId ? [{ model: Enterprise, as: 'enterprise', where: enterpriseFilter, attributes: [] }] : []
      }),
      // Funnel: Midline (has at least 2 reports)
      DiagnosisReport.count({
        distinct: true,
        col: 'CoachingSession.enterprise_id',
        include: [{ 
          model: CoachingSession, 
          as: 'session', 
          attributes: [],
          include: institutionId ? [{ model: Enterprise, as: 'enterprise', where: enterpriseFilter, attributes: [] }] : []
        }]
      }),
      // QC Health
      QcAudit.count({ where: { status: 'passed' } }),
      QcAudit.count({ where: { status: 'failed' } })
    ]);

    return {
      stats: {
        totalActive,
        totalGraduated,
      },
      graduationFunnel: {
        baseline: baselineCount,
        training: trainingCount,
        coaching: coachingCount,
        midline: midlineCount,
        graduated: totalGraduated
      },
      qcStats: {
        passed: qcPassed,
        failed: qcFailed,
        totalReview: qcPassed + qcFailed
      }
    };
  }
  /**
   * Aggregate a live activity feed chronologically.
   * Coaches see only their own events; supervisors/admins see institution-wide events.
   */
  async getActivityFeed(user) {
    const isCoach = user.role === 'coach';
    const coachFilter = isCoach ? { coach_id: user.id } : {};
    const institutionFilter = user.institution_id
      ? { institution_id: user.institution_id }
      : {};

    const limit = 30;

    const [sessions, phoneLogs, enterprises] = await Promise.all([
      CoachingSession.findAll({
        where: coachFilter,
        limit,
        order: [['scheduled_date', 'DESC']],
        include: [
          { model: Enterprise, as: 'enterprise', attributes: ['business_name'] },
          { model: User, as: 'coach', attributes: ['name'] }
        ]
      }),
      PhoneFollowupLog.findAll({
        where: coachFilter,
        limit,
        order: [['date', 'DESC']],
        include: [{ model: Enterprise, as: 'enterprise', attributes: ['business_name'] }]
      }),
      Enterprise.findAll({
        where: isCoach ? coachFilter : institutionFilter,
        limit,
        order: [['registered_at', 'DESC']],
        attributes: ['id', 'business_name', 'registered_at', 'status']
      })
    ]);

    const feed = [
      ...sessions.map(s => ({
        id: `session-${s.id}`,
        type: 'session',
        title: `Coaching: ${s.enterprise?.business_name || 'Enterprise'}`,
        description: s.title || s.session_type || 'Session recorded',
        timestamp: s.scheduled_date,
        actor: s.coach?.name || 'Coach'
      })),
      ...phoneLogs.map(p => ({
        id: `phone-${p.id}`,
        type: 'phone_call',
        title: `Phone Follow-up: ${p.enterprise?.business_name || 'Enterprise'}`,
        description: p.purpose || 'Phone contact made',
        timestamp: p.date,
        actor: 'Coach'
      })),
      ...enterprises.map(e => ({
        id: `enterprise-${e.id}`,
        type: 'enterprise',
        title: `Enterprise: ${e.business_name}`,
        description: `Status: ${e.status}`,
        timestamp: e.registered_at,
        actor: 'System'
      }))
    ]
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, limit);

    return feed;
  }

  /**
   * Returns Coach CRM portfolio — all enterprises assigned to the coach,
   * each with IAP task completion stats.
   */
  async getCoachPortfolio(coachId) {
    const { IndividualActionPlan, IapTask } = require('../models');

    const enterprises = await Enterprise.findAll({
      where: { coach_id: coachId },
      include: [
        {
          model: IndividualActionPlan,
          as: 'actionPlans',
          include: [{ model: IapTask, as: 'tasks', attributes: ['status', 'deadline'] }]
        }
      ],
      order: [['registered_at', 'DESC']]
    });

    const portfolio = enterprises.map(e => {
      const tasks = e.actionPlans?.flatMap(iap => iap.tasks) || [];
      const totalTasks = tasks.length;
      const completedTasks = tasks.filter(t => t.status === 'completed').length;
      const overdueTasks = tasks.filter(
        t => t.status === 'pending' && new Date(t.deadline) < new Date()
      ).length;

      return {
        id: e.id,
        businessName: e.business_name,
        ownerName: e.owner_name,
        sector: e.sector,
        location: e.location,
        status: e.status,
        lastActivity: e.last_activity_date,
        iapProgress: {
          total: totalTasks,
          completed: completedTasks,
          overdue: overdueTasks,
          percentage: totalTasks === 0 ? 0 : Math.round((completedTasks / totalTasks) * 100)
        }
      };
    });

    return portfolio;
  }
}

module.exports = new DashboardService();
