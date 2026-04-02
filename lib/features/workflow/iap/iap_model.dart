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
      id: json['id']?.toString() ?? '',
      enterpriseId: json['enterprise_id']?.toString() ?? '',
      coachId: json['coach_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      signoffDate: json['signoff_date'] != null
          ? DateTime.tryParse(json['signoff_date'].toString())
          : null,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => IapTaskModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
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
      id: json['id']?.toString() ?? '',
      iapId: json['iap_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString()) ?? DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      status: json['status']?.toString() ?? 'pending',
      evidenceUrl: json['evidence_url']?.toString(),
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
