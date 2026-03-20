import 'training_entity.dart';

class TrainingModel extends TrainingEntity {
  TrainingModel({
    required super.id,
    required super.title,
    super.description,
    required super.trainerId,
    required super.date,
    super.location,
    super.status = TrainingStatus.upcoming,
    super.attendances = const [],
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      trainerId: json['trainer_id'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      status: _parseStatus(json['status']),
      attendances: (json['Attendances'] as List? ?? [])
          .map((a) => TrainingAttendanceModel.fromJson(a))
          .toList(),
    );
  }

  static TrainingStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed': return TrainingStatus.completed;
      case 'cancelled': return TrainingStatus.cancelled;
      default: return TrainingStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'trainer_id': trainerId,
      'date': date.toIso8601String(),
      'location': location,
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
  });

  factory TrainingAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TrainingAttendanceModel(
      id: json['id'],
      trainingId: json['training_id'],
      enterpriseId: json['enterprise_id'],
      enterpriseName: json['Enterprise']?['business_name'],
      attended: json['attended'] ?? false,
      feedbackScore: json['feedback_score'],
    );
  }
}
