import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_datasource.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachRemoteDataSource remoteDataSource;

  CoachRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CoachEntity>>> getCoaches() async {
    try {
      final models = await remoteDataSource.getCoaches();
      final entities = models.map((e) => CoachEntity(
            id: e.id,
            name: e.name,
            email: e.email,
            isActive: e.isActive,
            createdAt: e.createdAt,
          )).toList();
      return Right(entities);
    } on AppException catch (e) {
      if (e.message.contains('401') || e.message.contains('403')) {
        return Left(UnauthorizedFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> getCoachDetails(String id) async {
    try {
      final model = await remoteDataSource.getCoachDetails(id);
      return Right(CoachEntity(
        id: model.id,
        name: model.name,
        email: model.email,
        isActive: model.isActive,
        createdAt: model.createdAt,
      ));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> registerCoach(String name, String email, String phone) async {
    try {
      final model = await remoteDataSource.registerCoach(name, email, phone);
      return Right(CoachEntity(
        id: model.id,
        name: model.name,
        email: model.email,
        isActive: model.isActive,
        createdAt: model.createdAt,
      ));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
