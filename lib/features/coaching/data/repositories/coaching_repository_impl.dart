import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/coaching_session_entity.dart';
import '../../domain/repositories/coaching_repository.dart';
import '../datasources/coaching_remote_datasource.dart';
import '../models/coaching_session_model.dart';

class CoachingRepositoryImpl implements CoachingRepository {
  final CoachingRemoteDataSource remoteDataSource;

  CoachingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CoachingSessionEntity>> createSession(CoachingSessionEntity session) async {
    try {
      final model = CoachingSessionModel(
        id: session.id,
        enterpriseId: session.enterpriseId,
        coachId: session.coachId,
        scheduledDate: session.scheduledDate,
        status: session.status,
        problemsIdentified: session.problemsIdentified,
        recommendations: session.recommendations,
        notes: session.notes,
      );
      final result = await remoteDataSource.createSession(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getMySessions() async {
    try {
      final result = await remoteDataSource.getMySessions();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachingSessionEntity>>> getEnterpriseSessions(String enterpriseId) async {
    try {
      final result = await remoteDataSource.getEnterpriseSessions(enterpriseId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
