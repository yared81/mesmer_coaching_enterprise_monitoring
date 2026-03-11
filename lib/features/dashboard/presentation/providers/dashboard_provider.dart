import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/domain/repositories/dashboard_repository.dart';

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
