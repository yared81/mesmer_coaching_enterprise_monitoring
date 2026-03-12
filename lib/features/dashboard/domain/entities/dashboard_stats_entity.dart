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
  final double avgAssessmentScore;
  final List<ActivityEntity> recentActivity;

  });
}

class CoachStatsEntity {
  final int totalEnterprises;
  final int totalSessions;
  final int pendingTasks;
  final double avgAssessmentScore;
  final List<ActivityEntity> recentActivity;

  CoachStatsEntity({
    required this.totalEnterprises,
    required this.totalSessions,
    required this.pendingTasks,
    required this.avgAssessmentScore,
    required this.recentActivity,
  });
}
