enum TrainingStatus { upcoming, completed, cancelled }

class TrainingEntity {
  final String id;
  final String title;
  final String? description;
  final String trainerId;
  final DateTime date;
  final String? location;
  final TrainingStatus status;
  final List<TrainingAttendanceEntity> attendances;

  const TrainingEntity({
    required this.id,
    required this.title,
    this.description,
    required this.trainerId,
    required this.date,
    this.location,
    this.status = TrainingStatus.upcoming,
    this.attendances = const [],
  });
}

class TrainingAttendanceEntity {
  final String id;
  final String trainingId;
  final String enterpriseId;
  final String? enterpriseName;
  final bool attended;
  final int? feedbackScore;

  const TrainingAttendanceEntity({
    required this.id,
    required this.trainingId,
    required this.enterpriseId,
    this.enterpriseName,
    required this.attended,
    this.feedbackScore,
  });
}
