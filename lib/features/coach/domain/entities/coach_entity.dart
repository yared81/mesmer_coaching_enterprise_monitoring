import 'package:equatable/equatable.dart';

class CoachEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isActive;
  final String? createdAt;

  const CoachEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, isActive, createdAt];
}
