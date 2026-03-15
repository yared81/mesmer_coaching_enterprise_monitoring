class RadarScore {
  final String name;
  final double value;

  RadarScore({required this.name, required this.value});

  factory RadarScore.fromJson(Map<String, dynamic> json) {
    return RadarScore(
      name: json['name'] ?? '',
      value: (json['value'] as num).toDouble(),
    );
  }
}

class EnterpriseDashboardStats {
  final String businessName;
  final String sector;
  final List<RadarScore> radarScores;
  final String latestRecommendation;
  final int totalSessions;
  final String? lastSessionDate;

  EnterpriseDashboardStats({
    required this.businessName,
    required this.sector,
    required this.radarScores,
    required this.latestRecommendation,
    required this.totalSessions,
    this.lastSessionDate,
  });
}
