enum Sector { agriculture, manufacturing, trade, services, construction, other }

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
  });

  final String id;
  final String businessName;
  final String ownerName;
  final Sector sector;
  final int employeeCount;
  final String location;
  final String phone;
  final String? email;
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
      coachId: coachId ?? this.coachId,
      institutionId: institutionId ?? this.institutionId,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
