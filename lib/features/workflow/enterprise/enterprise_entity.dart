enum Sector { agriculture, manufacturing, trade, services, construction, other }
enum OwnerGender { male, female, other }
enum PremiseType { rented, owned, home_based, other }

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
    this.businessAge,
    this.ownerGender,
    this.premiseType,
    this.baselineScore,
  });

  final String id;
  final String businessName;
  final String ownerName;
  final Sector sector;
  final int employeeCount;
  final String location;
  final String phone;
  final String? email;
  final int? businessAge;
  final OwnerGender? ownerGender;
  final PremiseType? premiseType;
  final double? baselineScore;
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
    int? businessAge,
    OwnerGender? ownerGender,
    PremiseType? premiseType,
    double? baselineScore,
    String? coachId,
    String? institutionId,
    DateTime? registeredAt,
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
      businessAge: businessAge ?? this.businessAge,
      ownerGender: ownerGender ?? this.ownerGender,
      premiseType: premiseType ?? this.premiseType,
      baselineScore: baselineScore ?? this.baselineScore,
      coachId: coachId ?? this.coachId,
      institutionId: institutionId ?? this.institutionId,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
