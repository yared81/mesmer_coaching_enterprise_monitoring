import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/diagnosis_template_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/diagnosis_remote_datasource.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final DiagnosisRemoteDataSource remoteDataSource;

  DiagnosisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DiagnosisTemplateEntity>>> listTemplates() async {
    try {
      final templates = await remoteDataSource.listTemplates();
      return Right(templates.map((tpl) => tpl.toEntity()).toList());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, DiagnosisTemplateEntity>> getLatestTemplate() async {
    try {
      final result = await remoteDataSource.getLatestTemplate();
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, DiagnosisTemplateEntity>> getTemplateById(String id) async {
    try {
      final result = await remoteDataSource.getTemplateById(id);
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, DiagnosisTemplateEntity>> createTemplate(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createTemplate(data);
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, DiagnosisTemplateEntity>> updateTemplate(String id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateTemplate(id, data);
      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getReportBySessionId(String sessionId) async {
    try {
      final result = await remoteDataSource.getReportBySessionId(sessionId);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitDiagnosis(
    String sessionId,
    String templateId,
    Map<String, String> responses,
  ) async {
    try {
      final result = await remoteDataSource.submitDiagnosis(
        sessionId,
        templateId,
        responses,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTemplate(String id) async {
    try {
      await remoteDataSource.deleteTemplate(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
