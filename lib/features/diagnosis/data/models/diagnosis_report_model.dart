import 'package:mesmer_coaching_enterprise_monitoring/core/utils/num_utils.dart';

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
      totalScore: NumUtils.toDouble(json['total_score']),
      maxScore: NumUtils.toDouble(json['max_score']),
      healthPercentage: NumUtils.toDouble(json['health_percentage']),
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
      averageScore: NumUtils.toDouble(json['average_score']),
      sumPoints: NumUtils.toDouble(json['sum_points']),
      percentage: NumUtils.toDouble(json['percentage']),
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
      points: NumUtils.toDouble(json['points']),
      maxPoints: NumUtils.toDouble(json['max_points']),
    );
  }
}
