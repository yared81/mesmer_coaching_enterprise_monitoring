import 'user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String institutionId;
  final String? institutionName;
  final String? enterpriseId;
  final CoachModel? coach;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institutionId,
    this.institutionName,
    this.enterpriseId,
    this.coach,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _parseRole(json['role']),
      institutionId: json['institution_id'] as String,
      institutionName: json['institution'] as String?,
      enterpriseId: json['enterprise_id'] as String?,
      coach: json['coach'] != null ? CoachModel.fromJson(json['coach'] as Map<String, dynamic>) : null,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'super_admin') return UserRole.superAdmin;
    if (role == 'admin') return UserRole.admin;
    if (role == 'supervisor') return UserRole.supervisor;
    if (role == 'coach') return UserRole.coach;
    if (role == 'data_verifier') return UserRole.dataVerifier;
    if (role == 'me_officer') return UserRole.meOfficer;
    if (role == 'program_manager') return UserRole.programManager;
    if (role == 'trainer') return UserRole.trainer;
    if (role == 'enterprise_user') return UserRole.enterprise;
    
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
      );
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

  CoachEntity toEntity() => CoachEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
      );
}
