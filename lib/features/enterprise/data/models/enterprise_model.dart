import 'package:mesmer_coaching_enterprise_monitoring/core/utils/num_utils.dart';
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
    this.businessAge,
    this.ownerGender,
    this.premiseType,
    this.baselineScore,
  });

  final String id;
  final String businessName;
  final String ownerName;
  final String sector;
  final int employeeCount;
  final String location;
  final String phone;
  final String? email;
  final int? businessAge;
  final String? ownerGender;
  final String? premiseType;
  final double? baselineScore;
  final String coachId;
  final String institutionId;
  final DateTime registeredAt;

  factory EnterpriseModel.fromJson(Map<String, dynamic> json) {
    return EnterpriseModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      ownerName: json['owner_name'] as String,
      sector: json['sector'] as String,
      employeeCount: NumUtils.toInt(json['employee_count']),
      location: json['location'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      businessAge: json['business_age'] != null ? NumUtils.toInt(json['business_age']) : null,
      ownerGender: json['owner_gender'] as String?,
      premiseType: json['premise_type'] as String?,
      baselineScore: json['baseline_score'] != null ? NumUtils.toDouble(json['baseline_score']) : null,
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
      businessAge: businessAge,
      ownerGender: _mapStringToGender(ownerGender),
      premiseType: _mapStringToPremiseType(premiseType),
      baselineScore: baselineScore,
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

  static OwnerGender? _mapStringToGender(String? gender) {
    if (gender == null) return null;
    return OwnerGender.values.firstWhere(
      (g) => g.name == gender,
      orElse: () => OwnerGender.other,
    );
  }

  static PremiseType? _mapStringToPremiseType(String? type) {
    if (type == null) return null;
    return PremiseType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => PremiseType.other,
    );
  }
}
