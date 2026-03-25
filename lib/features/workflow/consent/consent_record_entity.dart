import 'package:equatable/equatable.dart';

class ConsentRecordEntity extends Equatable {
  final String id;
  final String enterpriseId;
  final String recordedBy;
  final String consentVersion;
  final String method;
  final bool isConsented;
  final bool safeguardingAcknowledged;
  final DateTime signedAt;
  final String? notes;

  const ConsentRecordEntity({
    required this.id,
    required this.enterpriseId,
    required this.recordedBy,
    required this.consentVersion,
    required this.method,
    required this.isConsented,
    required this.safeguardingAcknowledged,
    required this.signedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        enterpriseId,
        recordedBy,
        consentVersion,
        method,
        isConsented,
        safeguardingAcknowledged,
        signedAt,
        notes,
      ];
}
