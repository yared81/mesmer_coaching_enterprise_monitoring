import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/domain/entities/dashboard_stats_entity.dart';

class ActivityModel extends ActivityEntity {
  ActivityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.timestamp,
    super.type,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: (json['business_name'] ?? json['name'] ?? 'Unknown') as String,
      description: json['coach'] != null 
          ? 'Coach: ${json['coach']['name']}' 
          : 'Enterprise activity',
      timestamp: DateTime.parse((json['registered_at'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()) as String),
      type: json['type'] as String? ?? 'enterprise',
    );
  }
}

class AdminStatsModel extends AdminStatsEntity {
  AdminStatsModel({
    required super.totalInstitutions,
    required super.totalCoaches,
    required super.totalEnterprises,
    required super.activePrograms,
    required super.recentEnterprises,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recent = (json['recentEnterprises'] as List)
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
    
    return AdminStatsModel(
      totalInstitutions: stats['totalInstitutions'] as int,
      totalCoaches: stats['totalCoaches'] as int,
      totalEnterprises: stats['totalEnterprises'] as int,
      activePrograms: stats['activePrograms'] as int,
      recentEnterprises: recent,
    );
  }
}

class SupervisorStatsModel extends SupervisorStatsEntity {
  SupervisorStatsModel({
    required super.totalCoaches,
    required super.totalEnterprises,
    required super.avgAssessmentScore,
    required super.recentActivity,
  });

  factory SupervisorStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recent = (json['recentActivity'] as List)
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SupervisorStatsModel(
      totalCoaches: stats['totalCoaches'] as int,
      totalEnterprises: stats['totalEnterprises'] as int,
      avgAssessmentScore: (stats['avgAssessmentScore'] as num).toDouble(),
      recentActivity: recent,
    );
  }
}

class CoachStatsModel extends CoachStatsEntity {
  CoachStatsModel({
    required super.totalEnterprises,
    required super.totalSessions,
    required super.pendingTasks,
    required super.avgAssessmentScore,
    required super.recentActivity,
  });

  factory CoachStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recent = (json['recentActivity'] as List)
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CoachStatsModel(
      totalEnterprises: stats['totalEnterprises'] as int,
      totalSessions: stats['totalSessions'] as int,
      pendingTasks: stats['pendingTasks'] as int,
      avgAssessmentScore: (stats['avgAssessmentScore'] as num).toDouble(),
      recentActivity: recent,
    );
  }
}
