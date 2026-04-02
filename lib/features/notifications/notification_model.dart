import 'package:mesmer_digital_coaching/features/notifications/notification_entity.dart';

class NotificationModel {
  static NotificationEntity fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
