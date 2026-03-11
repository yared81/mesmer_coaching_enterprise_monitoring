// TODO: EnterpriseEntity — pure domain object
// Fields: id, businessName, ownerName, sector, employeeCount, location,
//         phone, email, coachId, institutionId, registeredAt
// Sectors: agriculture, manufacturing, trade, services, construction

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

  // TODO: Add copyWith
}
