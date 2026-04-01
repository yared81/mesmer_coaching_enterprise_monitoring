import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'coaching_session_entity.dart';

class CoachingSessionModel extends CoachingSessionEntity {
  const CoachingSessionModel({
    required super.id,
    required super.title,
    required super.enterpriseId,
    required super.coachId,
    required super.scheduledDate,
    required super.status,
    super.sessionNumber,
    super.followupType,
    super.revenueGrowthPercent,
    super.currentEmployees,
    super.jobsCreated,
    super.qcStatus,
    super.qcFeedback,
    super.latitude,
    super.longitude,
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
      sessionNumber: NumUtils.toInt(json['session_number']),
      followupType: json['followup_type'] != null 
          ? FollowupType.values.byName(json['followup_type'] as String)
          : FollowupType.physical,
      revenueGrowthPercent: NumUtils.toDouble(json['revenue_growth_percent']),
      currentEmployees: NumUtils.toInt(json['current_employees']),
      jobsCreated: NumUtils.toInt(json['jobs_created']),
      qcStatus: json['qc_status'] != null 
          ? QcStatus.values.byName(json['qc_status'] as String)
          : QcStatus.pending,
      qcFeedback: json['qc_feedback'] as String?,
      latitude: NumUtils.toDouble(json['latitude']),
      longitude: NumUtils.toDouble(json['longitude']),
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
      'followup_type': followupType.name,
      'qc_status': qcStatus.name,
      'qc_feedback': qcFeedback,
      'latitude': latitude,
      'longitude': longitude,
      'session_number': sessionNumber,
      'revenue_growth_percent': revenueGrowthPercent,
      'current_employees': currentEmployees,
      'jobs_created': jobsCreated,
      if (templateId != null) 'template_id': templateId,
      'problems_identified': problemsIdentified,
      'recommendations': recommendations,
      'notes': notes,
    };
  }
}
