import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/domain/entities/assessment_entity.dart';

// TODO: DiagnosisResultEntity — summarises the assessment outcome
class DiagnosisResultEntity {
  const DiagnosisResultEntity({
    required this.assessmentId,
    required this.enterpriseId,
    required this.overallScore,
    required this.categoryScores,
    required this.priorityAreas,
    required this.generatedAt,
  });

  final String assessmentId;
  final String enterpriseId;
  final double overallScore;                        // 0–100
  final Map<AssessmentCategory, double> categoryScores;
  final List<String> priorityAreas;
  final DateTime generatedAt;
}
