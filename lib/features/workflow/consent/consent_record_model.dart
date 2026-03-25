import 'consent_record_entity.dart';

class ConsentRecordModel extends ConsentRecordEntity {
  const ConsentRecordModel({
    required super.id,
    required super.enterpriseId,
    required super.recordedBy,
    required super.consentVersion,
    required super.method,
    required super.isConsented,
    required super.safeguardingAcknowledged,
    required super.signedAt,
    super.notes,
  });

  factory ConsentRecordModel.fromJson(Map<String, dynamic> json) {
    return ConsentRecordModel(
      id: json['id'] ?? '',
      enterpriseId: json['enterprise_id'] ?? '',
      recordedBy: json['recorded_by'] ?? '',
      consentVersion: json['consent_version'] ?? '1.0',
      method: json['method'] ?? 'checkbox',
      isConsented: json['is_consented'] ?? false,
      safeguardingAcknowledged: json['safeguarding_acknowledged'] ?? false,
      signedAt: DateTime.parse(json['signed_at']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enterprise_id': enterpriseId,
      'recorded_by': recordedBy,
      'consent_version': consentVersion,
      'method': method,
      'is_consented': isConsented,
      'safeguarding_acknowledged': safeguardingAcknowledged,
      'signed_at': signedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
