import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, AdminStatsEntity>> getAdminStats();
  Future<Either<Failure, SupervisorStatsEntity>> getSupervisorStats();
  Future<Either<Failure, CoachStatsEntity>> getCoachStats();
  Future<Either<Failure, CoachStatsEntity>> getCoachStatsById(String id);
  Future<Either<Failure, List<dynamic>>> getNotifications();
  Future<Either<Failure, MeStatsEntity>> getMeStats();
}
