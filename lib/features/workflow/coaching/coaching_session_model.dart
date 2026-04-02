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

  factory CoachingSessionModel.fromEntity(CoachingSessionEntity e, {String? overrideId}) {
    return CoachingSessionModel(
      id: overrideId ?? e.id,
      title: e.title,
      enterpriseId: e.enterpriseId,
      coachId: e.coachId,
      scheduledDate: e.scheduledDate,
      status: e.status,
      sessionNumber: e.sessionNumber,
      followupType: e.followupType,
      revenueGrowthPercent: e.revenueGrowthPercent,
      currentEmployees: e.currentEmployees,
      jobsCreated: e.jobsCreated,
      qcStatus: e.qcStatus,
      qcFeedback: e.qcFeedback,
      latitude: e.latitude,
      longitude: e.longitude,
      templateId: e.templateId,
      enterpriseName: e.enterpriseName,
      problemsIdentified: e.problemsIdentified,
      recommendations: e.recommendations,
      notes: e.notes,
    );
  }

  factory CoachingSessionModel.fromJson(Map<String, dynamic> json) {
    return CoachingSessionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Coaching Session',
      enterpriseId: json['enterprise_id']?.toString() ?? '',
      coachId: json['coach_id']?.toString() ?? '',
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.tryParse(json['scheduled_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: SessionStatus.values.firstWhere(
        (s) => s.name == (json['status']?.toString() ?? 'scheduled'),
        orElse: () => SessionStatus.scheduled,
      ),
      sessionNumber: NumUtils.toInt(json['session_number']),
      followupType: json['followup_type'] != null
          ? FollowupType.values.firstWhere(
              (f) => f.name == json['followup_type'].toString(),
              orElse: () => FollowupType.physical,
            )
          : FollowupType.physical,
      revenueGrowthPercent: NumUtils.toDouble(json['revenue_growth_percent']),
      currentEmployees: NumUtils.toInt(json['current_employees']),
      jobsCreated: NumUtils.toInt(json['jobs_created']),
      qcStatus: json['qc_status'] != null
          ? QcStatus.values.firstWhere(
              (q) => q.name == json['qc_status'].toString(),
              orElse: () => QcStatus.pending,
            )
          : QcStatus.pending,
      qcFeedback: json['qc_feedback']?.toString(),
      latitude: NumUtils.toDouble(json['latitude']),
      longitude: NumUtils.toDouble(json['longitude']),
      templateId: json['template_id']?.toString(),
      enterpriseName: json['enterprise'] != null
          ? json['enterprise']['business_name']?.toString()
          : null,
      problemsIdentified: json['problems_identified']?.toString(),
      recommendations: json['recommendations']?.toString(),
      notes: json['notes']?.toString(),
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
