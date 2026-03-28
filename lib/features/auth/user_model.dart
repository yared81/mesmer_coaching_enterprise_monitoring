import 'user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String institutionId;
  final String? institutionName;
  final String? enterpriseId;
  final bool isActive;
  final CoachModel? coach;
  final int? enterpriseCount;
  final int? sessionCount;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institutionId,
    required this.isActive,
    this.institutionName,
    this.enterpriseId,
    this.coach,
    this.enterpriseCount,
    this.sessionCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _parseRole(json['role']),
      institutionId: json['institution_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      institutionName: _parseInstitution(json['institution']),
      enterpriseId: json['enterprise_id'] as String?,
      coach: json['coach'] != null ? CoachModel.fromJson(json['coach'] as Map<String, dynamic>) : null,
      enterpriseCount: json['enterpriseCount'] != null ? int.tryParse(json['enterpriseCount'].toString()) : null,
      sessionCount: json['sessionCount'] != null ? int.tryParse(json['sessionCount'].toString()) : null,
    );
  }

  static String? _parseInstitution(dynamic institution) {
    if (institution == null) return null;
    if (institution is String) return institution;
    if (institution is Map) return institution['name'] as String?;
    return null;
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'super_admin') return UserRole.superAdmin;
    if (role == 'program_manager') return UserRole.programManager;
    if (role == 'regional_coordinator') return UserRole.regionalCoordinator;
    if (role == 'me_officer') return UserRole.meOfficer;
    if (role == 'data_verifier') return UserRole.dataVerifier;
    if (role == 'trainer') return UserRole.trainer;
    if (role == 'coach') return UserRole.coach;
    if (role == 'enumerator') return UserRole.enumerator;
    if (role == 'comms_officer') return UserRole.commsOfficer;
    if (role == 'enterprise_user') return UserRole.enterprise;
    if (role == 'stakeholder') return UserRole.stakeholder;
    
    throw Exception('CRITICAL SECURITY ERROR: Unrecognized user role "$role" detected from API. Authentication safely aborted.');
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        role: role,
        institutionId: institutionId,
        institutionName: institutionName,
        enterpriseId: enterpriseId,
        coach: coach?.toEntity(),
        enterpriseCount: enterpriseCount,
        sessionCount: sessionCount,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': _roleToString(role),
      'institution_id': institutionId,
      'is_active': isActive,
      'institution': institutionName,
      'enterprise_id': enterpriseId,
      'coach': coach?.toJson(),
      'enterpriseCount': enterpriseCount,
      'sessionCount': sessionCount,
    };
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'super_admin';
      case UserRole.programManager: return 'program_manager';
      case UserRole.regionalCoordinator: return 'regional_coordinator';
      case UserRole.meOfficer: return 'me_officer';
      case UserRole.dataVerifier: return 'data_verifier';
      case UserRole.trainer: return 'trainer';
      case UserRole.coach: return 'coach';
      case UserRole.enumerator: return 'enumerator';
      case UserRole.commsOfficer: return 'comms_officer';
      case UserRole.enterprise: return 'enterprise_user';
      case UserRole.stakeholder: return 'stakeholder';
      default: return 'unknown';
    }
  }
}

class CoachModel {
  final String id;
  final String name;
  final String email;
  final String? phone;

  CoachModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  UserCoachEntity toEntity() => UserCoachEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
