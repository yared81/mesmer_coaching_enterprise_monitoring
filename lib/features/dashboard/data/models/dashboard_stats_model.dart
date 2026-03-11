import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats_model.g.dart';

@JsonSerializable()
class AdminStatsModel extends AdminStatsEntity {
  AdminStatsModel({
    @JsonKey(name: 'totalInstitutions') required super.totalInstitutions,
    @JsonKey(name: 'totalCoaches') required super.totalCoaches,
    @JsonKey(name: 'totalEnterprises') required super.totalEnterprises,
    @JsonKey(name: 'activePrograms') required super.activePrograms,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) => _$AdminStatsModelFromJson(json);
}

@JsonSerializable()
class SupervisorStatsModel extends SupervisorStatsEntity {
  SupervisorStatsModel({
    @JsonKey(name: 'totalCoaches') required super.totalCoaches,
    @JsonKey(name: 'totalEnterprises') required super.totalEnterprises,
    @JsonKey(name: 'avgAssessmentScore') required super.avgAssessmentScore,
  });

  factory SupervisorStatsModel.fromJson(Map<String, dynamic> json) => _$SupervisorStatsModelFromJson(json);
}
