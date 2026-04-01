// TODO: CoachingSessionEntity — domain object for a coaching session
// Each enterprise can have multiple sessions over time

enum SessionStatus { scheduled, completed, cancelled }
enum FollowupType { physical, phone }
enum QcStatus { pending, approved, flagged, audited_pass, audited_fail }

class CoachingSessionEntity {
  const CoachingSessionEntity({
    required this.id,
    required this.title,
    required this.enterpriseId,
    required this.coachId,
    required this.scheduledDate,
    required this.status,
    this.sessionNumber,
    this.followupType = FollowupType.physical,
    this.revenueGrowthPercent = 0.0,
    this.currentEmployees = 0,
    this.jobsCreated = 0,
    this.qcStatus = QcStatus.pending,
    this.qcFeedback,
    this.latitude,
    this.longitude,
    this.templateId,
    this.enterpriseName,
    this.problemsIdentified,
    this.recommendations,
    this.notes,
    this.coachSignature,
    this.enterpriseSignature,
  });

  final String id;
  final String title;
  final String enterpriseId;
  final String? enterpriseName;
  final String coachId;
  final DateTime scheduledDate;
  final SessionStatus status;
  final int? sessionNumber;
  final FollowupType followupType;
  final double revenueGrowthPercent;
  final int currentEmployees;
  final int jobsCreated;
  final QcStatus qcStatus;
  final String? qcFeedback;
  final double? latitude;
  final double? longitude;
  final String? templateId;
  final String? problemsIdentified;
  final String? recommendations;
  final String? notes;
  final String? coachSignature;
  final String? enterpriseSignature;

  factory CoachingSessionEntity.fromJson(Map<String, dynamic> json) {
    return CoachingSessionEntity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      enterpriseId: json['enterprise_id'] ?? '',
      enterpriseName: json['enterprise']?['business_name'],
      coachId: json['coach_id'] ?? '',
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date']) 
          : DateTime.now(),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'scheduled'),
        orElse: () => SessionStatus.scheduled,
      ),
      sessionNumber: json['session_number'],
      followupType: FollowupType.values.firstWhere(
        (e) => e.name == (json['followup_type'] ?? 'physical'),
        orElse: () => FollowupType.physical,
      ),
      revenueGrowthPercent: double.tryParse(json['revenue_growth_percent']?.toString() ?? '0') ?? 0.0,
      currentEmployees: json['current_employees'] ?? 0,
      jobsCreated: json['jobs_created'] ?? 0,
      qcStatus: QcStatus.values.firstWhere(
        (e) => e.name == (json['qc_status'] ?? 'pending'),
        orElse: () => QcStatus.pending,
      ),
      qcFeedback: json['qc_feedback'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      templateId: json['template_id'],
      problemsIdentified: json['problems_identified'],
      recommendations: json['recommendations'],
      notes: json['notes'],
      coachSignature: json['coach_signature'],
      enterpriseSignature: json['enterprise_signature'],
    );
  }
}
