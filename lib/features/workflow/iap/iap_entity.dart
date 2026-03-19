enum IapStatus { active, completed }
enum IapTaskStatus { pending, completed }

class IapEntity {
  const IapEntity({
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
  final IapStatus status;
  final DateTime? signoffDate;
  final List<IapTaskEntity> tasks;
  
  IapEntity copyWith({
    String? id,
    String? enterpriseId,
    String? coachId,
    IapStatus? status,
    DateTime? signoffDate,
    List<IapTaskEntity>? tasks,
  }) {
    return IapEntity(
      id: id ?? this.id,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      coachId: coachId ?? this.coachId,
      status: status ?? this.status,
      signoffDate: signoffDate ?? this.signoffDate,
      tasks: tasks ?? this.tasks,
    );
  }
}

class IapTaskEntity {
  const IapTaskEntity({
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
  final IapTaskStatus status;
  final String? evidenceUrl;
  
  IapTaskEntity copyWith({
    String? id,
    String? iapId,
    String? description,
    DateTime? deadline,
    IapTaskStatus? status,
    String? evidenceUrl,
  }) {
    return IapTaskEntity(
      id: id ?? this.id,
      iapId: iapId ?? this.iapId,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
    );
  }
}
