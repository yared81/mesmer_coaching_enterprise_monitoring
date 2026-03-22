import 'package:json_annotation/json_annotation.dart';

// TODO: UserEntity — pure domain object, no JSON or Flutter dependencies
// Fields: id, email, name, role, institutionId, createdAt

enum UserRole {
  @JsonValue('admin') admin,
  @JsonValue('super_admin') superAdmin,
  @JsonValue('supervisor') supervisor,
  @JsonValue('coach') coach,
  @JsonValue('data_verifier') dataVerifier,
  @JsonValue('me_officer') meOfficer,
  @JsonValue('program_manager') programManager,
  @JsonValue('trainer') trainer,
  @JsonValue('enterprise_user') enterprise
}

class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institutionId,
    this.institutionName,
    this.enterpriseId,
    this.coach,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String institutionId;
  final String? institutionName;
  final String? enterpriseId;
  final CoachEntity? coach;
}

class CoachEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const CoachEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });
}
