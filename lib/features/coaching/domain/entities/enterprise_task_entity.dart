// TODO: EnterpriseTaskEntity — a task assigned to an enterprise after a session
class EnterpriseTaskEntity {
  const EnterpriseTaskEntity({
    required this.id,
    required this.sessionId,
    required this.enterpriseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });

  final String id;
  final String sessionId;
  final String enterpriseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
}
