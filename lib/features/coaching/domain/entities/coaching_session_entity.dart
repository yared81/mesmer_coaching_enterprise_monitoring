// TODO: CoachingSessionEntity — domain object for a coaching session
// Each enterprise can have multiple sessions over time

enum SessionStatus { scheduled, completed, cancelled }

class CoachingSessionEntity {
  const CoachingSessionEntity({
    required this.id,
    required this.title,
    required this.enterpriseId,
    required this.coachId,
    required this.scheduledDate,
    required this.status,
    this.templateId,
    this.problemsIdentified,
    this.recommendations,
    this.notes,
  });

  final String id;
  final String title;
  final String enterpriseId;
  final String coachId;
  final DateTime scheduledDate;
  final SessionStatus status;
  final String? templateId;
  final String? problemsIdentified;
  final String? recommendations;
  final String? notes;
  // TODO: tasks (List<EnterpriseTaskEntity>) and evidence (List<UploadedEvidenceEntity>)
}
