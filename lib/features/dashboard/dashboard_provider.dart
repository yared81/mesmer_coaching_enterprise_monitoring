import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_remote_datasource.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_repository_impl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  );
});

final adminStatsProvider = FutureProvider<AdminStatsEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getAdminStats();
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});

final supervisorStatsProvider = FutureProvider<SupervisorStatsEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getSupervisorStats();
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});

final coachStatsProvider = FutureProvider<CoachStatsEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getCoachStats();
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});

final coachStatsByIdProvider = FutureProvider.family<CoachStatsEntity, String>((ref, id) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getCoachStatsById(id);
  return result.fold(
    (failure) => throw failure.message,
    (stats) => stats,
  );
});

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getNotifications();
  return result.fold(
    (failure) => throw failure.message,
    (notifications) => notifications,
  );
});
