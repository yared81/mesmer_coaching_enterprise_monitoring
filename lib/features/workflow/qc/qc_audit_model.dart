import 'qc_audit_entity.dart';

class QcAuditModel extends QcAuditEntity {
  const QcAuditModel({
    required super.id,
    required super.targetType,
    required super.targetId,
    super.verifierId,
    required super.isRandomSample,
    required super.status,
    super.auditorComments,
    this.flagReason,
    required super.createdAt,
  });

  @override
  final String? flagReason;

  factory QcAuditModel.fromJson(Map<String, dynamic> json) {
    return QcAuditModel(
      id: json['id'] as String,
      targetType: _parseTargetType(json['target_type']),
      targetId: json['target_id'] as String,
      verifierId: json['verifier_id'] as String?,
      isRandomSample: json['is_random_sample'] as bool? ?? false,
      status: QcAuditStatus.values.byName(json['status'] as String),
      auditorComments: json['auditor_comments'] as String?,
      flagReason: json['flag_reason'] as String?,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()) as String,
      ),
    );
  }

  static QcTargetType _parseTargetType(String type) {
    if (type == 'baseline') return QcTargetType.baseline;
    if (type == 'session') return QcTargetType.session;
    return QcTargetType.endline;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'auditor_comments': auditorComments,
    };
  }
}
