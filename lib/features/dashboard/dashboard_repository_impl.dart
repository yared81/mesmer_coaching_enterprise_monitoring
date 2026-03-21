import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_remote_datasource.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/dashboard_stats_entity.dart';
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
      return Right(stats);
    } catch (e) {
      return Left(Failure.fromException(e));
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
