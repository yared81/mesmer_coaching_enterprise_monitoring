import '../../domain/entities/enterprise_dashboard_stats.dart';

class EnterpriseDashboardModel extends EnterpriseDashboardStats {
  EnterpriseDashboardModel({
    required super.businessName,
    required super.sector,
    required super.radarScores,
    required super.latestRecommendation,
    required super.totalSessions,
    super.lastSessionDate,
  });

  factory EnterpriseDashboardModel.fromJson(Map<String, dynamic> json) {
    final enterprise = json['enterprise'] as Map<String, dynamic>;
    final scores = (json['radarScores'] as List)
        .map((s) => RadarScore.fromJson(s))
        .toList();

    return EnterpriseDashboardModel(
      businessName: enterprise['businessName'] ?? '',
      sector: enterprise['sector'] ?? '',
      radarScores: scores,
      latestRecommendation: json['latestRecommendation'] ?? 'No recommendations yet.',
      totalSessions: json['totalSessions'] ?? 0,
      lastSessionDate: json['lastSessionDate'],
    );
  }
}
