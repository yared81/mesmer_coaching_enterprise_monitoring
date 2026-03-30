enum Sector { agriculture, manufacturing, trade, services, construction, other }
enum OwnerGender { male, female, other }
enum PremiseType { rented, owned, home_based, other }
enum RecordKeepingSystem { none, paper, digital, professional }
enum EnterpriseStatus { active, pilot, stalled, graduated, dropped }

class EnterpriseEntity {
  const EnterpriseEntity({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.sector,
    required this.employeeCount,
    required this.location,
    required this.phone,
    required this.coachId,
    required this.institutionId,
    required this.registeredAt,
    this.email,
    this.ownerAge,
    this.businessActivity,
    this.businessAge,
    this.ownerGender,
    this.premiseType,
    this.baselineScore,
    this.baselineEmployees = 0,
    this.baselineRevenue = 0.0,
    this.recordKeepingSystem,
    this.challenges,
    this.loanAmount = 0.0,
    this.consentStatus = false,
    this.consentDate,
    this.status = EnterpriseStatus.active,
    this.graduationDate,
    this.verificationCode,
  });

  final String id;
  final String businessName;
  final String ownerName;
  final Sector sector;
  final int employeeCount;
  final String location;
  final String phone;
  final String? email;
  final int? ownerAge;
  final String? businessActivity;
  final int? businessAge;
  final OwnerGender? ownerGender;
  final PremiseType? premiseType;
  final double? baselineScore;
  final int baselineEmployees;
  final double baselineRevenue;
  final RecordKeepingSystem? recordKeepingSystem;
  final String? challenges;
  final double loanAmount;
  final bool consentStatus;
  final DateTime? consentDate;
  final EnterpriseStatus status;
  final DateTime? graduationDate;
  final String? verificationCode;
  final String coachId;
  final String institutionId;
  final DateTime registeredAt;

  EnterpriseEntity copyWith({
    String? id,
    String? businessName,
    String? ownerName,
    Sector? sector,
    int? employeeCount,
    String? location,
    String? phone,
    String? email,
    int? ownerAge,
    String? businessActivity,
    int? businessAge,
    OwnerGender? ownerGender,
    PremiseType? premiseType,
    double? baselineScore,
    int? baselineEmployees,
    double? baselineRevenue,
    RecordKeepingSystem? recordKeepingSystem,
    String? challenges,
    double? loanAmount,
    bool? consentStatus,
    DateTime? consentDate,
    EnterpriseStatus? status,
    String? coachId,
    String? institutionId,
    DateTime? registeredAt,
    DateTime? graduationDate,
    String? verificationCode,
  }) {
    return EnterpriseEntity(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      sector: sector ?? this.sector,
      employeeCount: employeeCount ?? this.employeeCount,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ownerAge: ownerAge ?? this.ownerAge,
      businessActivity: businessActivity ?? this.businessActivity,
      businessAge: businessAge ?? this.businessAge,
      ownerGender: ownerGender ?? this.ownerGender,
      premiseType: premiseType ?? this.premiseType,
      baselineScore: baselineScore ?? this.baselineScore,
      baselineEmployees: baselineEmployees ?? this.baselineEmployees,
      baselineRevenue: baselineRevenue ?? this.baselineRevenue,
      recordKeepingSystem: recordKeepingSystem ?? this.recordKeepingSystem,
      challenges: challenges ?? this.challenges,
      loanAmount: loanAmount ?? this.loanAmount,
      consentStatus: consentStatus ?? this.consentStatus,
      consentDate: consentDate ?? this.consentDate,
      status: status ?? this.status,
      coachId: coachId ?? this.coachId,
      institutionId: institutionId ?? this.institutionId,
      registeredAt: registeredAt ?? this.registeredAt,
      graduationDate: graduationDate ?? this.graduationDate,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }
}
