import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/diagnosis_template_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/diagnosis_remote_datasource.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final DiagnosisRemoteDataSource remoteDataSource;

  DiagnosisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DiagnosisTemplateEntity>> getLatestTemplate() async {
    try {
      final result = await remoteDataSource.getLatestTemplate();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getReportBySessionId(String sessionId) async {
    try {
      final result = await remoteDataSource.getReportBySessionId(sessionId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses,
  }) async {
    try {
      final result = await remoteDataSource.submitDiagnosis(
        sessionId: sessionId,
        templateId: templateId,
        responses: responses,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
