import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import 'qc_audit_entity.dart';
import 'qc_audit_model.dart';

class QcRemoteDataSource {
  final Dio _dio;
  const QcRemoteDataSource(this._dio);

  Future<List<QcAuditModel>> getPendingAudits() async {
    final response = await _dio.get('/qc-audits/pending');
    final List data = response.data['data'];
    return data.map((json) => QcAuditModel.fromJson(json)).toList();
  }

  Future<List<QcAuditModel>> getAuditHistory() async {
    final response = await _dio.get('/qc-audits/history');
    final List data = response.data['data'];
    return data.map((json) => QcAuditModel.fromJson(json)).toList();
  }

  Future<void> reviewAudit(String id, QcAuditStatus status, String? comments) async {
    await _dio.put('/qc-audits/$id/review', data: {
      'status': status.name,
      'auditor_comments': comments,
    });
  }

  Future<QcAuditModel> getAuditById(String id) async {
    final response = await _dio.get('/qc-audits/$id');
    return QcAuditModel.fromJson(response.data['data']);
  }
}

abstract class QcRepository {
  Future<Either<Failure, List<QcAuditEntity>>> getPendingAudits();
  Future<Either<Failure, List<QcAuditEntity>>> getAuditHistory();
  Future<Either<Failure, QcAuditEntity>> getAuditById(String id);
  Future<Either<Failure, void>> reviewAudit(String id, QcAuditStatus status, String? comments);
}

class QcRepositoryImpl implements QcRepository {
  final QcRemoteDataSource remoteDataSource;
  const QcRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<QcAuditEntity>>> getPendingAudits() async {
    try {
      final audits = await remoteDataSource.getPendingAudits();
      return Right(audits);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed'));
    }
  }

  @override
  Future<Either<Failure, List<QcAuditEntity>>> getAuditHistory() async {
    try {
      final audits = await remoteDataSource.getAuditHistory();
      return Right(audits);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch history failed'));
    }
  }

  @override
  Future<Either<Failure, void>> reviewAudit(String id, QcAuditStatus status, String? comments) async {
    try {
      await remoteDataSource.reviewAudit(id, status, comments);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Review failed'));
    }
  }

  @override
  Future<Either<Failure, QcAuditEntity>> getAuditById(String id) async {
    try {
      final audit = await remoteDataSource.getAuditById(id);
      return Right(audit);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed'));
    }
  }
}
