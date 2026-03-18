// TODO: AssessmentEntity — represents a completed or in-progress business assessment
// Categories: finance, marketing, operations, humanResources, governance
// Each category has scored questions (0-3 scale)

enum AssessmentCategory { finance, marketing, operations, humanResources, governance }
enum AssessmentStatus { draft, completed }

class AssessmentEntity {
  const AssessmentEntity({
    required this.id,
    required this.enterpriseId,
    required this.coachId,
    required this.responses,
    required this.status,
    required this.conductedAt,
    this.totalScore,
    this.priorityAreas,
  });

  final String id;
  final String enterpriseId;
  final String coachId;
  final Map<String, dynamic> responses; // questionId → score
  final AssessmentStatus status;
  final DateTime conductedAt;
  final double? totalScore;             // calculated by backend
  final List<String>? priorityAreas;   // auto-identified challenge areas
}
