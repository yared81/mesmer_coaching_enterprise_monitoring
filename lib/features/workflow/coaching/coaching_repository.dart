import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'coaching_session_entity.dart';

abstract class CoachingRepository {
  Future<Either<Failure, CoachingSessionEntity>> createSession(CoachingSessionEntity session);
  Future<Either<Failure, List<CoachingSessionEntity>>> getMySessions();
  Future<Either<Failure, List<CoachingSessionEntity>>> getEnterpriseSessions(String enterpriseId);
  Future<Either<Failure, CoachingSessionEntity>> updateSession(CoachingSessionEntity session);
}
