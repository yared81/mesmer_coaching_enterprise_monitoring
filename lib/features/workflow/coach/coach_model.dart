import 'package:json_annotation/json_annotation.dart';

part 'coach_model.g.dart';

@JsonSerializable()
class CoachModel {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  CoachModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    this.createdAt,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) => _$CoachModelFromJson(json);
  Map<String, dynamic> toJson() => _$CoachModelToJson(this);
}
