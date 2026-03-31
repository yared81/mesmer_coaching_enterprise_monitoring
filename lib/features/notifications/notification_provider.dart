import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/notifications/notification_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/notifications/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(dioProvider));
});

final notificationsProvider = FutureProvider<List<NotificationEntity>>((ref) async {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      _ref.invalidate(notificationsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _ref.invalidate(notificationsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      _ref.invalidate(notificationsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationActionProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider), ref);
});
