import '../../domain/entities/coaching_session_entity.dart';

class CoachingSessionModel extends CoachingSessionEntity {
  const CoachingSessionModel({
    required super.id,
    required super.enterpriseId,
    required super.coachId,
    required super.scheduledDate,
    required super.status,
    super.problemsIdentified,
    super.recommendations,
    super.notes,
  });

  factory CoachingSessionModel.fromJson(Map<String, dynamic> json) {
    return CoachingSessionModel(
      id: json['id'] as String,
      enterpriseId: json['enterprise_id'] as String,
      coachId: json['coach_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: SessionStatus.values.byName(json['status'] as String),
      problemsIdentified: json['problems_identified'] as String?,
      recommendations: json['recommendations'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'enterprise_id': enterpriseId,
      'coach_id': coachId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status.name,
      'problems_identified': problemsIdentified,
      'recommendations': recommendations,
      'notes': notes,
    };
  }
}
