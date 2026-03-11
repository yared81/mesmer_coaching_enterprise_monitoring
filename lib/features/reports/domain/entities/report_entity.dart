// TODO: ReportEntity — aggregated program performance data for supervisor/admin
class ReportEntity {
  const ReportEntity({
    required this.totalEnterprises,
    required this.activeCoaches,
    required this.totalSessions,
    required this.averageImprovementScore,
    required this.enterprisesByRegion,
    required this.sessionsByMonth,
    required this.generatedAt,
  });

  final int totalEnterprises;
  final int activeCoaches;
  final int totalSessions;
  final double averageImprovementScore;
  final Map<String, int> enterprisesByRegion;
  final Map<String, int> sessionsByMonth;
  final DateTime generatedAt;
}
