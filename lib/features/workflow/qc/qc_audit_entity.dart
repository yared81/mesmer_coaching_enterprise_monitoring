enum QcAuditStatus { pending, passed, failed }
enum QcTargetType { baseline, session, endline }

class QcAuditEntity {
  final String id;
  final QcTargetType targetType;
  final String targetId;
  final String? verifierId;
  final bool isRandomSample;
  final QcAuditStatus status;
  final String? auditorComments;
  final String? flagReason;
  final DateTime createdAt;

  const QcAuditEntity({
    required this.id,
    required this.targetType,
    required this.targetId,
    this.verifierId,
    required this.isRandomSample,
    required this.status,
    this.auditorComments,
    this.flagReason,
    required this.createdAt,
  });
}
