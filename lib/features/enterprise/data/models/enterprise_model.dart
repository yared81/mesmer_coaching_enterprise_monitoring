import '../../domain/entities/enterprise_entity.dart';

class EnterpriseModel {
  const EnterpriseModel({
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
  final String sector;
  final int employeeCount;
  final String location;
  final String phone;
  final String? email;
  final String coachId;
  final String institutionId;
  final DateTime registeredAt;

  factory EnterpriseModel.fromJson(Map<String, dynamic> json) {
    return EnterpriseModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      ownerName: json['owner_name'] as String,
      sector: json['sector'] as String,
      employeeCount: json['employee_count'] as int,
      location: json['location'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      coachId: json['coach_id'] as String,
      institutionId: json['institution_id'] as String,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );
  }

  EnterpriseEntity toEntity() {
    return EnterpriseEntity(
      id: id,
      businessName: businessName,
      ownerName: ownerName,
      sector: _mapStringToSector(sector),
      employeeCount: employeeCount,
      location: location,
      phone: phone,
      email: email,
      coachId: coachId,
      institutionId: institutionId,
      registeredAt: registeredAt,
    );
  }

  static Sector _mapStringToSector(String sector) {
    return Sector.values.firstWhere(
      (s) => s.name == sector,
      orElse: () => Sector.other,
    );
  }
}
