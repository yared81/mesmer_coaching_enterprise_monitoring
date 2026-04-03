import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/features/notifications/notification_entity.dart';
import 'package:mesmer_digital_coaching/features/notifications/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;
  NotificationRepositoryImpl(this._dio);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get('/notifications');
    final List data = (response.data['data'] as List?) ?? [];
    return data.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.put('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
  }
}
