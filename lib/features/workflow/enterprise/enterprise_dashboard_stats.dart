import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';

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

  factory EnterpriseDashboardStats.fromJson(Map<String, dynamic> json) {
    final ent = json['enterprise'] as Map<String, dynamic>?;
    return EnterpriseDashboardStats(
      enterpriseId: ent?['id'] ?? json['enterprise_id'] ?? '',
      businessName: ent?['businessName'] ?? json['business_name'] ?? '',
      sector: ent?['sector'] ?? json['sector'] ?? '',
      radarScores: (json['radarScores'] as List? ?? [])
          .map((e) => RadarScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestRecommendation: json['latestRecommendation'] ?? '',
      totalSessions: json['totalSessions'] ?? 0,
      lastSessionDate: json['lastSessionDate'],
    );
  }
}
