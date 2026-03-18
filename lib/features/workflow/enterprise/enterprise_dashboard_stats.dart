import 'package:mesmer_coaching_enterprise_monitoring/core/utils/num_utils.dart';

class RadarScore {
  final String name;
  final double value;

  RadarScore({required this.name, required this.value});

  factory RadarScore.fromJson(Map<String, dynamic> json) {
    return RadarScore(
      name: json['name'] ?? '',
      value: NumUtils.toDouble(json['value']),
    );
  }
}

class EnterpriseDashboardStats {
  final String enterpriseId;
  final String businessName;
  final String sector;
  final List<RadarScore> radarScores;
  final String latestRecommendation;
  final int totalSessions;
  final String? lastSessionDate;

  EnterpriseDashboardStats({
    required this.enterpriseId,
    required this.businessName,
    required this.sector,
    required this.radarScores,
    required this.latestRecommendation,
    required this.totalSessions,
    this.lastSessionDate,
  });
}
