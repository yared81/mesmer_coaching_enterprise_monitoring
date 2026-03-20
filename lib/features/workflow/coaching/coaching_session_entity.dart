// TODO: CoachingSessionEntity — domain object for a coaching session
// Each enterprise can have multiple sessions over time

enum SessionStatus { scheduled, completed, cancelled }
enum FollowupType { physical, phone }
enum QcStatus { pending, approved, flagged }

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
  // TODO: tasks (List<EnterpriseTaskEntity>) and evidence (List<UploadedEvidenceEntity>)
}
