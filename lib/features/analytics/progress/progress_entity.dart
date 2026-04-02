class ProgressEntity {
  const ProgressEntity({
    required this.enterpriseId,
    required this.baselineScore,
    required this.latestScore,
    required this.improvementPercentage,
    required this.indicators,
    required this.trends,
    required this.lastUpdated,
  });

  final String enterpriseId;
  final double baselineScore;
  final double latestScore;
  final double improvementPercentage;
  final Map<String, double> indicators; // category name → score (0–5)
  final List<Map<String, dynamic>> trends; // [{date, score, sessionTitle}]
  final DateTime lastUpdated;
}
