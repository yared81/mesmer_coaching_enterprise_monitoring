class ActivityEntity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? type;

  ActivityEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.type,
  });
}

class AdminStatsEntity {
  final int totalInstitutions;
  final int totalCoaches;
  final int totalEnterprises;
  final int activePrograms;
  final List<ActivityEntity> recentEnterprises;

  AdminStatsEntity({
    required this.totalInstitutions,
    required this.totalCoaches,
    required this.totalEnterprises,
    required this.activePrograms,
    required this.recentEnterprises,
  });
}

class SupervisorStatsEntity {
  final int totalCoaches;
  final int totalEnterprises;
  final int totalAssessments;
  final double avgAssessmentScore;
  final List<ActivityEntity> recentActivity;

  SupervisorStatsEntity({
    required this.totalCoaches,
    required this.totalEnterprises,
    required this.totalAssessments,
    required this.avgAssessmentScore,
    required this.recentActivity,
  });
}

class CoachStatsEntity {
  final int totalEnterprises;
  final int totalSessions;
  final int pendingTasks;
  final double avgAssessmentScore;
  final List<ActivityEntity> recentActivity;
  final List<ActivityEntity> recentInteractions;

  CoachStatsEntity({
    required this.totalEnterprises,
    required this.totalSessions,
    required this.pendingTasks,
    required this.avgAssessmentScore,
    required this.recentActivity,
    required this.recentInteractions,
  });
}

class MeStatsEntity {
  final int totalActive;
  final int totalGraduated;
  final Map<String, int> graduationFunnel;
  final Map<String, int> qcStats;

  MeStatsEntity({
    required this.totalActive,
    required this.totalGraduated,
    required this.graduationFunnel,
    required this.qcStats,
  });
}
