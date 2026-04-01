import 'package:mesmer_digital_coaching/features/notifications/notification_entity.dart';

class NotificationModel {
  static NotificationEntity fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'].toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(NotificationEntity entity) {
    return {
      'id': entity.id,
      'title': entity.title,
      'message': entity.message,
      'type': entity.type,
      'created_at': entity.createdAt.toIso8601String(),
      'is_read': entity.isRead,
    };
  }
}
