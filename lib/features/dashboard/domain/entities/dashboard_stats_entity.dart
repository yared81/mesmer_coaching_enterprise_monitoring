class AdminStatsEntity {
  final int totalInstitutions;
  final int totalCoaches;
  final int totalEnterprises;
  final int activePrograms;

  AdminStatsEntity({
    required this.totalInstitutions,
    required this.totalCoaches,
    required this.totalEnterprises,
    required this.activePrograms,
  });
}

class SupervisorStatsEntity {
  final int totalCoaches;
  final int totalEnterprises;
  final double avgAssessmentScore;

  SupervisorStatsEntity({
    required this.totalCoaches,
    required this.totalEnterprises,
    required this.avgAssessmentScore,
  });
}
