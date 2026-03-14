class DiagnosisReportModel {
  final String id;
  final String sessionId;
  final double totalScore;
  final double maxScore;
  final double healthPercentage;
  final Map<String, CategoryScore> categoryScores;
  final List<PrimaryChallenge> primaryChallenges;

  DiagnosisReportModel({
    required this.id,
    required this.sessionId,
    required this.totalScore,
    required this.maxScore,
    required this.healthPercentage,
    required this.categoryScores,
    required this.primaryChallenges,
  });

  factory DiagnosisReportModel.fromJson(Map<String, dynamic> json) {
    final catScores = <String, CategoryScore>{};
    if (json['category_scores'] != null) {
      (json['category_scores'] as Map<String, dynamic>).forEach((key, value) {
        catScores[key] = CategoryScore.fromJson(value);
      });
    }

    final challenges = <PrimaryChallenge>[];
    if (json['primary_challenges'] != null) {
      for (var item in json['primary_challenges']) {
        challenges.add(PrimaryChallenge.fromJson(item));
      }
    }

    return DiagnosisReportModel(
      id: json['id'],
      sessionId: json['session_id'],
      totalScore: (json['total_score'] as num).toDouble(),
      maxScore: (json['max_score'] as num).toDouble(),
      healthPercentage: (json['health_percentage'] as num).toDouble(),
      categoryScores: catScores,
      primaryChallenges: challenges,
    );
  }
}

class CategoryScore {
  final double averageScore;
  final double sumPoints;
  final double percentage;

  CategoryScore({
    required this.averageScore,
    required this.sumPoints,
    required this.percentage,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      averageScore: (json['average_score'] as num).toDouble(),
      sumPoints: (json['sum_points'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class PrimaryChallenge {
  final String questionId;
  final String categoryName;
  final String questionText;
  final String selectedChoice;
  final double points;
  final double maxPoints;

  PrimaryChallenge({
    required this.questionId,
    required this.categoryName,
    required this.questionText,
    required this.selectedChoice,
    required this.points,
    required this.maxPoints,
  });

  factory PrimaryChallenge.fromJson(Map<String, dynamic> json) {
    return PrimaryChallenge(
      questionId: json['question_id'],
      categoryName: json['category_name'],
      questionText: json['question_text'],
      selectedChoice: json['selected_choice'],
      points: (json['points'] as num).toDouble(),
      maxPoints: (json['max_points'] as num).toDouble(),
    );
  }
}
