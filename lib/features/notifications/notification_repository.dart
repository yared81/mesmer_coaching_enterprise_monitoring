import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/notifications/notification_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/notifications/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;
  NotificationRepositoryImpl(this._dio);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get('/api/v1/notifications');
    final List data = response.data['data'];
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.put('/api/v1/notifications/$id/read');
  }
}
