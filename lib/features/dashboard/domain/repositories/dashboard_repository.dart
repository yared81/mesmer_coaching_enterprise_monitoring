import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, AdminStatsEntity>> getAdminStats();
  Future<Either<Failure, SupervisorStatsEntity>> getSupervisorStats();
  Future<Either<Failure, CoachStatsEntity>> getCoachStats();
  Future<Either<Failure, CoachStatsEntity>> getCoachStatsById(String id);
  Future<Either<Failure, List<dynamic>>> getNotifications();
}
