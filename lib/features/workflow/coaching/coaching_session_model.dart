import 'coaching_session_entity.dart';

class CoachingSessionModel extends CoachingSessionEntity {
  const CoachingSessionModel({
    required super.id,
    required super.title,
    required super.enterpriseId,
    required super.coachId,
    required super.scheduledDate,
    required super.status,
    super.templateId,
    super.enterpriseName,
    super.problemsIdentified,
    super.recommendations,
    super.notes,
  });

  factory CoachingSessionModel.fromJson(Map<String, dynamic> json) {
    return CoachingSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      enterpriseId: json['enterprise_id'] as String,
      coachId: json['coach_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: SessionStatus.values.byName(json['status'] as String),
      templateId: json['template_id'] as String?,
      enterpriseName: json['enterprise'] != null ? json['enterprise']['business_name'] as String? : null,
      problemsIdentified: json['problems_identified'] as String?,
      recommendations: json['recommendations'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'enterprise_id': enterpriseId,
      'coach_id': coachId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status.name,
      if (templateId != null) 'template_id': templateId,
      'problems_identified': problemsIdentified,
      'recommendations': recommendations,
      'notes': notes,
    };
  }
}
