import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_remote_datasource.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_model.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminStatsEntity>> getAdminStats() async {
    try {
      final stats = await remoteDataSource.getAdminStats();
      return Right(stats);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SupervisorStatsEntity>> getSupervisorStats() async {
    try {
      final stats = await remoteDataSource.getSupervisorStats();
      return Right(stats);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, CoachStatsEntity>> getCoachStats() async {
    try {
      final stats = await remoteDataSource.getCoachStats();
      
      // Save full stats model to cache
      await HiveStorage.cacheDashboardStats('coach_default', jsonEncode(stats.toJson()));

      return Right(stats);
    } catch (e) {
      final failure = Failure.fromException(e);
      if (failure is NetworkFailure) {
        try {
          final cachedString = HiveStorage.getCachedDashboardStats('coach_default');
          if (cachedString != null) {
            final Map<String, dynamic> jsonMap = jsonDecode(cachedString);
            final cachedStats = CoachStatsModel.fromJson(jsonMap);
            return Right(cachedStats);
          }
        } catch (_) {}
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, CoachStatsEntity>> getCoachStatsById(String id) async {
    try {
      final stats = await remoteDataSource.getCoachStatsById(id);
      return Right(stats);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, MeStatsEntity>> getMeStats() async {
    try {
      final stats = await remoteDataSource.getMeStats();
      return Right(stats);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
