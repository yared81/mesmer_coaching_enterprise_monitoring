// TODO: ProgressEntity — tracks an enterprise's improvement over time
// Compared from baseline assessment vs latest assessment

class ProgressEntity {
  const ProgressEntity({
    required this.enterpriseId,
    required this.baselineScore,
    required this.latestScore,
    required this.improvementPercentage,
    required this.indicators,
    required this.lastUpdated,
  });

  final String enterpriseId;
  final double baselineScore;
  final double latestScore;
  final double improvementPercentage;
  final Map<String, double> indicators; // e.g. {'bookkeeping': 0.6, 'sales': 0.4}
  final DateTime lastUpdated;
}
