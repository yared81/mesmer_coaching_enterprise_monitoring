import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/coaching_session_entity.dart';

abstract class CoachingRepository {
  Future<Either<Failure, CoachingSessionEntity>> createSession(CoachingSessionEntity session);
  Future<Either<Failure, List<CoachingSessionEntity>>> getMySessions();
  Future<Either<Failure, List<CoachingSessionEntity>>> getEnterpriseSessions(String enterpriseId);
  Future<Either<Failure, CoachingSessionEntity>> updateSession(CoachingSessionEntity session);
}
