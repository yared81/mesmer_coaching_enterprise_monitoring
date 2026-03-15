import 'package:json_annotation/json_annotation.dart';

// TODO: UserEntity — pure domain object, no JSON or Flutter dependencies
// Fields: id, email, name, role, institutionId, createdAt

enum UserRole {
  @JsonValue('admin') admin,
  @JsonValue('supervisor') supervisor,
  @JsonValue('coach') coach,
  @JsonValue('enterprise') enterprise
}

class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institutionId,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String institutionId;

  // TODO: Add copyWith if needed
}
