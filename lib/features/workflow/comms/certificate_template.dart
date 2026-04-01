import 'package:json_annotation/json_annotation.dart';

part 'certificate_template.g.dart';

enum CertificateStatus {
  @JsonValue('pending') pending,
  @JsonValue('approved') approved,
  @JsonValue('issued') issued,
  @JsonValue('revoked') revoked,
}

enum GraduationStatus {
  @JsonValue('ready_for_certificate') readyForCertificate,
  @JsonValue('baseline_pending') baselinePending,
  @JsonValue('insufficient_coaching') insufficientCoaching,
  @JsonValue('midline_pending') midlinePending,
  @JsonValue('coach_signoff_pending') coachSignoffPending,
  @JsonValue('insufficient_evidence') insufficientEvidence,
  @JsonValue('not_eligible') notEligible,
}

class CertificateTemplate {
  final String id;
  final String enterpriseId;
  final String enterpriseName;
  final String ownerName;
  final String programName;
  final DateTime issueDate;
  final DateTime completionDate;
  final String verificationCode;
  final String coachName;
  final String regionalCoordinator;
  final List<String> achievements;
  final CertificateStatus status;
  final String? certificateNumber;
  final String? pdfFileUrl;

  const CertificateTemplate({
    required this.id,
    required this.enterpriseId,
    required this.enterpriseName,
    required this.ownerName,
    required this.programName,
    required this.issueDate,
    required this.completionDate,
    required this.verificationCode,
    required this.coachName,
    required this.regionalCoordinator,
    required this.achievements,
    required this.status,
    this.certificateNumber,
    this.pdfFileUrl,
  });

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) =>
      _$CertificateTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateTemplateToJson(this);

  CertificateTemplate copyWith({
    String? id,
    String? enterpriseId,
    String? enterpriseName,
    String? ownerName,
    String? programName,
    DateTime? issueDate,
    DateTime? completionDate,
    String? verificationCode,
    String? coachName,
    String? regionalCoordinator,
    List<String>? achievements,
    CertificateStatus? status,
    String? certificateNumber,
    String? pdfFileUrl,
  }) {
    return CertificateTemplate(
      id: id ?? this.id,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      enterpriseName: enterpriseName ?? this.enterpriseName,
      ownerName: ownerName ?? this.ownerName,
      programName: programName ?? this.programName,
      issueDate: issueDate ?? this.issueDate,
      completionDate: completionDate ?? this.completionDate,
      verificationCode: verificationCode ?? this.verificationCode,
      coachName: coachName ?? this.coachName,
      regionalCoordinator: regionalCoordinator ?? this.regionalCoordinator,
      achievements: achievements ?? this.achievements,
      status: status ?? this.status,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      pdfFileUrl: pdfFileUrl ?? this.pdfFileUrl,
    );
  }
}

class CertificateVerification {
  final String certificateId;
  final String verificationCode;
  final DateTime verifiedAt;
  final String? ipAddress;
  final String? userAgent;

  const CertificateVerification({
    required this.certificateId,
    required this.verificationCode,
    required this.verifiedAt,
    this.ipAddress,
    this.userAgent,
  });

  factory CertificateVerification.fromJson(Map<String, dynamic> json) {
    return CertificateVerification(
      certificateId: json['certificate_id'] ?? '',
      verificationCode: json['verification_code'] ?? '',
      verifiedAt: DateTime.parse(json['verified_at']),
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_id': certificateId,
      'verification_code': verificationCode,
      'verified_at': verifiedAt.toIso8601String(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }
}
