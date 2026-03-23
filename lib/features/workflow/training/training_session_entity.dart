// TrainingSessionEntity — domain object for a training session

enum TrainingModule { bookkeeping, marketing, customer_service, business_planning, financial_management, other }

enum TrainingStatus { scheduled, completed, cancelled }

class TrainingSessionEntity {
  const TrainingSessionEntity({
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

  factory TrainingSessionEntity.fromJson(Map<String, dynamic> json) {
    return TrainingSessionEntity(
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
