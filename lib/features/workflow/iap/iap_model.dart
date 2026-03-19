import 'iap_entity.dart';

class IapModel {
  const IapModel({
    required this.id,
    required this.enterpriseId,
    required this.coachId,
    required this.status,
    this.signoffDate,
    required this.tasks,
  });

  final String id;
  final String enterpriseId;
  final String coachId;
  final String status;
  final DateTime? signoffDate;
  final List<IapTaskModel> tasks;

  factory IapModel.fromJson(Map<String, dynamic> json) {
    return IapModel(
      id: json['id'] as String,
      enterpriseId: json['enterprise_id'] as String,
      coachId: json['coach_id'] as String,
      status: json['status'] as String? ?? 'active',
      signoffDate: json['signoff_date'] != null ? DateTime.parse(json['signoff_date'] as String) : null,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => IapTaskModel.fromJson(t as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  IapEntity toEntity() {
    return IapEntity(
      id: id,
      enterpriseId: enterpriseId,
      coachId: coachId,
      status: _mapStatus(status),
      signoffDate: signoffDate,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }

  static IapStatus _mapStatus(String status) {
    return IapStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => IapStatus.active,
    );
  }
}

class IapTaskModel {
  const IapTaskModel({
    required this.id,
    required this.iapId,
    required this.description,
    required this.deadline,
    required this.status,
    this.evidenceUrl,
  });

  final String id;
  final String iapId;
  final String description;
  final DateTime deadline;
  final String status;
  final String? evidenceUrl;

  factory IapTaskModel.fromJson(Map<String, dynamic> json) {
    return IapTaskModel(
      id: json['id'] as String,
      iapId: json['iap_id'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'pending',
      evidenceUrl: json['evidence_url'] as String?,
    );
  }

  IapTaskEntity toEntity() {
    return IapTaskEntity(
      id: id,
      iapId: iapId,
      description: description,
      deadline: deadline,
      status: _mapStatus(status),
      evidenceUrl: evidenceUrl,
    );
  }

  static IapTaskStatus _mapStatus(String status) {
    return IapTaskStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => IapTaskStatus.pending,
    );
  }
}
