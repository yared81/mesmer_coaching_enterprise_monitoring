// TrainingEntity — domain object for a training session

enum TrainingModule { bookkeeping, marketing, customerService, businessPlanning, financialManagement, other }

enum TrainingStatus { scheduled, completed, cancelled }

class TrainingEntity {
  const TrainingEntity({
    required this.id,
    required this.title,
    required this.module,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.capacity = 20,
    required this.trainerId,
    this.trainerName,
    this.notes,
    this.status = TrainingStatus.scheduled,
    this.attendeeCount = 0,
    this.attendances = const [],
  });

  final String id;
  final String title;
  final TrainingModule module;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final int capacity;
  final String trainerId;
  final String? trainerName;
  final String? notes;
  final TrainingStatus status;
  final int attendeeCount;
  final List<TrainingAttendanceEntity> attendances;

  factory TrainingEntity.fromJson(Map<String, dynamic> json) {
    return TrainingEntity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      module: TrainingModule.values.firstWhere(
        (e) => e.name == (json['module'] ?? 'other'),
        orElse: () => TrainingModule.other,
      ),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 20,
      trainerId: json['trainer_id'] ?? '',
      trainerName: json['trainer']?['name'],
      notes: json['notes'],
      status: TrainingStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'scheduled'),
        orElse: () => TrainingStatus.scheduled,
      ),
      attendeeCount: (json['attendees'] as List?)?.length ?? 0,
      attendances: (json['attendees'] as List?)
          ?.map((a) => TrainingAttendanceEntity.fromJson(a))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'module': module.name,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'capacity': capacity,
      'notes': notes,
      'status': status.name,
    };
  }
}

class TrainingAttendanceEntity {
  final String id;
  final String trainingId;
  final String enterpriseId;
  final String? enterpriseName;
  final bool attended;
  final int? feedbackScore;
  final String? trainerInsight;

  const TrainingAttendanceEntity({
    required this.id,
    required this.trainingId,
    required this.enterpriseId,
    this.enterpriseName,
    required this.attended,
    this.feedbackScore,
    this.trainerInsight,
  });

  factory TrainingAttendanceEntity.fromJson(Map<String, dynamic> json) {
    return TrainingAttendanceEntity(
      id: json['id'] ?? '',
      trainingId: json['training_id'] ?? '',
      enterpriseId: json['enterprise_id'] ?? '',
      enterpriseName: json['enterprise']?['business_name'],
      attended: json['attended'] ?? false,
      feedbackScore: json['feedback_score'],
      trainerInsight: json['trainer_insight'],
    );
  }
}

class TrainerStats {
  final int totalSessions;
  final int totalAttendees;
  final double averageScore;
  final int completionRate;

  TrainerStats({
    required this.totalSessions,
    required this.totalAttendees,
    required this.averageScore,
    required this.completionRate,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) {
    return TrainerStats(
      totalSessions: json['totalSessions'] ?? 0,
      totalAttendees: json['totalAttendees'] ?? 0,
      averageScore: double.tryParse(json['averageScore'].toString()) ?? 0.0,
      completionRate: int.tryParse(json['completionRate'].toString()) ?? 0,
    );
  }
}
