import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'enterprise_dashboard_stats.dart';

class EnterpriseDashboardModel extends EnterpriseDashboardStats {
  EnterpriseDashboardModel({
    required super.enterpriseId,
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
      enterpriseId: enterprise['id'] ?? '',
      businessName: enterprise['businessName'] ?? '',
      sector: enterprise['sector'] ?? '',
      radarScores: scores,
      latestRecommendation: json['latestRecommendation'] ?? 'No recommendations yet.',
      totalSessions: NumUtils.toInt(json['totalSessions']),
      lastSessionDate: json['lastSessionDate'],
    );
  }
}
