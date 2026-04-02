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

  factory ReportEntity.fromJson(Map<String, dynamic> json) {
    return ReportEntity(
      totalEnterprises: json['totalEnterprises'] ?? json['total_enterprises'] ?? 0,
      activeCoaches: json['activeCoaches'] ?? json['active_coaches'] ?? 0,
      totalSessions: json['totalSessions'] ?? json['total_sessions'] ?? 0,
      averageImprovementScore:
          (json['averageImprovementScore'] ?? json['average_improvement'] ?? 0.0)
              .toDouble(),
      enterprisesByRegion:
          Map<String, int>.from(json['enterprisesByRegion'] ?? {}),
      sessionsByMonth: Map<String, int>.from(json['sessionsByMonth'] ?? {}),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
    );
  }
}
