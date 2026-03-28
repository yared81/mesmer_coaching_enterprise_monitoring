import 'package:mesmer_coaching_enterprise_monitoring/core/utils/num_utils.dart';
import 'enterprise_entity.dart';

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
    this.baselineEmployees = 0,
    this.baselineRevenue = 0.0,
    this.recordKeepingSystem,
    this.challenges,
    this.loanAmount = 0.0,
    this.consentStatus = false,
    this.consentDate,
    this.status = 'active',
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
  final int baselineEmployees;
  final double baselineRevenue;
  final String? recordKeepingSystem;
  final String? challenges;
  final double loanAmount;
  final bool consentStatus;
  final DateTime? consentDate;
  final String status;
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
      baselineEmployees: NumUtils.toInt(json['baseline_employees']),
      baselineRevenue: NumUtils.toDouble(json['baseline_revenue']),
      recordKeepingSystem: json['record_keeping_system'] as String?,
      challenges: json['challenges'] as String?,
      loanAmount: NumUtils.toDouble(json['loan_amount']),
      consentStatus: json['consent_status'] == true,
      consentDate: json['consent_date'] != null ? DateTime.parse(json['consent_date'] as String) : null,
      status: json['status'] as String? ?? 'active',
      coachId: json['coach_id'] as String? ?? '',
      institutionId: json['institution_id'] as String? ?? '',
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
      baselineEmployees: baselineEmployees,
      baselineRevenue: baselineRevenue,
      recordKeepingSystem: _mapStringToRecordKeeping(recordKeepingSystem),
      challenges: challenges,
      loanAmount: loanAmount,
      consentStatus: consentStatus,
      consentDate: consentDate,
      status: _mapStringToStatus(status),
      coachId: coachId,
      institutionId: institutionId,
      registeredAt: registeredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'sector': sector,
      'employee_count': employeeCount,
      'location': location,
      'phone': phone,
      'email': email,
      'business_age': businessAge,
      'owner_gender': ownerGender,
      'premise_type': premiseType,
      'baseline_score': baselineScore,
      'baseline_employees': baselineEmployees,
      'baseline_revenue': baselineRevenue,
      'record_keeping_system': recordKeepingSystem,
      'challenges': challenges,
      'loan_amount': loanAmount,
      'consent_status': consentStatus,
      'consent_date': consentDate?.toIso8601String(),
      'status': status,
      'coach_id': coachId,
      'institution_id': institutionId,
      'registered_at': registeredAt.toIso8601String(),
    };
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

  static RecordKeepingSystem? _mapStringToRecordKeeping(String? type) {
    if (type == null) return null;
    return RecordKeepingSystem.values.firstWhere(
      (t) => t.name == type,
      orElse: () => RecordKeepingSystem.none,
    );
  }

  static EnterpriseStatus _mapStringToStatus(String status) {
    return EnterpriseStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => EnterpriseStatus.active,
    );
  }
}
