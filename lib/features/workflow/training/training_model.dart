import 'training_entity.dart';

class TrainingModel extends TrainingEntity {
  TrainingModel({
    required super.id,
    required super.title,
    required super.module,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.location,
    super.capacity = 20,
    required super.trainerId,
    super.trainerName,
    super.notes,
    super.status = TrainingStatus.scheduled,
    super.attendeeCount = 0,
    super.attendances = const [],
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      module: TrainingModule.values.firstWhere(
        (e) => e.name == (json['module']?.replaceAll('_', '') ?? 'other'),
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
      status: _parseStatus(json['status']),
      attendeeCount: (json['attendees'] as List?)?.length ?? 0,
      attendances: (json['attendees'] as List?)
          ?.map((a) => TrainingAttendanceModel.fromJson(a))
          .toList() ?? const [],
    );
  }

  static TrainingStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed': return TrainingStatus.completed;
      case 'cancelled': return TrainingStatus.cancelled;
      case 'scheduled': return TrainingStatus.scheduled;
      default: return TrainingStatus.scheduled;
    }
  }

  @override
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

class TrainingAttendanceModel extends TrainingAttendanceEntity {
  TrainingAttendanceModel({
    required super.id,
    required super.trainingId,
    required super.enterpriseId,
    super.enterpriseName,
    required super.attended,
    super.feedbackScore,
    super.trainerInsight,
  });

  factory TrainingAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TrainingAttendanceModel(
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
