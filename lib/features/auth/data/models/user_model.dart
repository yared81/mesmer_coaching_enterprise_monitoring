import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String institutionId;
  final String? institutionName;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institutionId,
    this.institutionName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _parseRole(json['role']),
      institutionId: json['institution_id'] as String,
      institutionName: json['institution'] as String?,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'admin') return UserRole.admin;
    if (role == 'supervisor') return UserRole.supervisor;
    if (role == 'coach') return UserRole.coach;
    if (role == 'enterprise') return UserRole.enterprise;
    return UserRole.coach; // Default
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        role: role,
        institutionId: institutionId,
        institutionName: institutionName,
      );
}
