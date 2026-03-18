import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_entity.dart';

abstract class CoachRepository {
  Future<Either<Failure, List<CoachEntity>>> getCoaches();
  Future<Either<Failure, CoachEntity>> getCoachDetails(String id);
  Future<Either<Failure, CoachEntity>> registerCoach(String name, String email, String phone);
}
