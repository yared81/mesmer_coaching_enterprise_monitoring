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
    super.flagReason,
    super.targetName,
    required super.createdAt,
  });



  factory QcAuditModel.fromJson(Map<String, dynamic> json) {
    return QcAuditModel(
      id: json['id']?.toString() ?? '',
      targetType: _parseTargetType(json['target_type']?.toString() ?? ''),
      targetId: json['target_id']?.toString() ?? '',
      verifierId: json['verifier_id']?.toString(),
      isRandomSample: json['is_random_sample'] as bool? ?? false,
      status: QcAuditStatus.values.firstWhere(
        (s) => s.name == (json['status']?.toString() ?? 'pending'),
        orElse: () => QcAuditStatus.pending,
      ),
      auditorComments: json['auditor_comments']?.toString(),
      flagReason: json['flag_reason']?.toString(),
      targetName: json['enterprise']?['business_name']?.toString() ??
          json['session']?['title']?.toString(),
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
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
