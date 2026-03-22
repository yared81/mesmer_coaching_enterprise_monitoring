import 'package:json_annotation/json_annotation.dart';

// TODO: UserEntity — pure domain object, no JSON or Flutter dependencies
// Fields: id, email, name, role, institutionId, createdAt

enum UserRole {
  @JsonValue('super_admin') superAdmin,
  @JsonValue('program_manager') programManager,
  @JsonValue('regional_coordinator') regionalCoordinator,
  @JsonValue('me_officer') meOfficer,
  @JsonValue('data_verifier') dataVerifier,
  @JsonValue('trainer') trainer,
  @JsonValue('coach') coach,
  @JsonValue('enumerator') enumerator,
  @JsonValue('comms_officer') commsOfficer,
  @JsonValue('enterprise_user') enterprise,
  @JsonValue('stakeholder') stakeholder
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
  final UserCoachEntity? coach;
}

class UserCoachEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const UserCoachEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });
}
