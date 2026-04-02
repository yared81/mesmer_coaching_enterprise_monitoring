enum CertificateStatus { pending, approved, issued, revoked }

enum GraduationStatus {
  readyForCertificate,
  baselinePending,
  insufficientCoaching,
  midlinePending,
  coachSignoffPending,
  insufficientEvidence,
  notEligible,
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

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) {
    return CertificateTemplate(
      id: json['id']?.toString() ?? '',
      enterpriseId: json['enterprise_id']?.toString() ?? '',
      enterpriseName: json['enterprise_name']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      programName: json['program_name']?.toString() ?? 'MESMER Digital Coaching Program',
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'].toString())
          : DateTime.now(),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'].toString())
          : DateTime.now(),
      verificationCode: json['verification_code']?.toString() ?? '',
      coachName: json['coach_name']?.toString() ?? '',
      regionalCoordinator: json['regional_coordinator']?.toString() ?? '',
      achievements: (json['achievements'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: CertificateStatus.values.firstWhere(
        (s) => s.name == (json['status']?.toString() ?? 'pending'),
        orElse: () => CertificateStatus.pending,
      ),
      certificateNumber: json['certificate_number']?.toString(),
      pdfFileUrl: json['pdf_file_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'enterprise_id': enterpriseId,
        'enterprise_name': enterpriseName,
        'owner_name': ownerName,
        'program_name': programName,
        'issue_date': issueDate.toIso8601String(),
        'completion_date': completionDate.toIso8601String(),
        'verification_code': verificationCode,
        'coach_name': coachName,
        'regional_coordinator': regionalCoordinator,
        'achievements': achievements,
        'status': status.name,
        'certificate_number': certificateNumber,
        'pdf_file_url': pdfFileUrl,
      };

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

  Map<String, dynamic> toJson() => {
        'certificate_id': certificateId,
        'verification_code': verificationCode,
        'verified_at': verifiedAt.toIso8601String(),
        'ip_address': ipAddress,
        'user_agent': userAgent,
      };
}
