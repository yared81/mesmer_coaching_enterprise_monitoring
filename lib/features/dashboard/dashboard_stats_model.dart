import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_stats_entity.dart';

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
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['business_name'] ?? json['name'] ?? 'Activity').toString(),
      description: (json['description'] ?? 'No details available').toString(),
      timestamp: DateTime.parse((json['timestamp'] ?? json['registered_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()).toString()),
      type: json['type']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
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
    final recent = List<ActivityEntity>.from(
      (json['recentEnterprises'] as List? ?? [])
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
    );
    
    return AdminStatsModel(
      totalInstitutions: NumUtils.toInt(stats['totalInstitutions']),
      totalCoaches: NumUtils.toInt(stats['totalCoaches']),
      totalEnterprises: NumUtils.toInt(stats['totalEnterprises']),
      activePrograms: NumUtils.toInt(stats['activePrograms']),
      recentEnterprises: recent,
    );
  }
}

class SupervisorStatsModel extends SupervisorStatsEntity {
  SupervisorStatsModel({
    required super.totalCoaches,
    required super.totalEnterprises,
    required super.totalAssessments,
    required super.avgAssessmentScore,
    required super.recentActivity,
  });

  factory SupervisorStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recent = List<ActivityEntity>.from(
      (json['recentActivity'] as List? ?? [])
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
    );

    return SupervisorStatsModel(
      totalCoaches: NumUtils.toInt(stats['totalCoaches']),
      totalEnterprises: NumUtils.toInt(stats['totalEnterprises']),
      totalAssessments: NumUtils.toInt(stats['totalAssessments']),
      avgAssessmentScore: NumUtils.toDouble(stats['avgAssessmentScore']),
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
    required super.recentInteractions,
  });

  factory CoachStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recent = List<ActivityEntity>.from(
      (json['recentActivity'] as List? ?? [])
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
    );

    final interactions = List<ActivityEntity>.from(
      (json['recentInteractions'] as List? ?? [])
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
    );

    return CoachStatsModel(
      totalEnterprises: NumUtils.toInt(stats['totalEnterprises']),
      totalSessions: NumUtils.toInt(stats['totalSessions']),
      pendingTasks: NumUtils.toInt(stats['pendingTasks']),
      avgAssessmentScore: NumUtils.toDouble(stats['avgAssessmentScore']),
      recentActivity: recent,
      recentInteractions: interactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': {
        'totalEnterprises': totalEnterprises,
        'totalSessions': totalSessions,
        'pendingTasks': pendingTasks,
        'avgAssessmentScore': avgAssessmentScore,
      },
      'recentActivity': recentActivity.map((e) => (e as ActivityModel).toJson()).toList(),
      'recentInteractions': recentInteractions.map((e) => (e as ActivityModel).toJson()).toList(),
    };
  }
}

class MeStatsModel extends MeStatsEntity {
  MeStatsModel({
    required super.totalActive,
    required super.totalGraduated,
    required super.graduationFunnel,
    required super.qcStats,
  });

  factory MeStatsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      json = json['data'] as Map<String, dynamic>;
    }
    
    final stats = (json['stats'] ?? {}) as Map<String, dynamic>;
    final funnel = Map<String, int>.from(json['graduationFunnel'] as Map? ?? {});
    final qc = Map<String, int>.from(json['qcStats'] as Map? ?? {});

    return MeStatsModel(
      totalActive: NumUtils.toInt(stats['totalActive']),
      totalGraduated: NumUtils.toInt(stats['totalGraduated']),
      graduationFunnel: funnel,
      qcStats: qc,
    );
  }
}
