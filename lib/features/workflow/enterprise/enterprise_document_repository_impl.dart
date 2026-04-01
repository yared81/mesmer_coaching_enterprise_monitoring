import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'enterprise_document_entity.dart';
import 'enterprise_document_repository.dart';
import 'enterprise_document_remote_datasource.dart';

class EnterpriseDocumentRepositoryImpl implements EnterpriseDocumentRepository {
  final EnterpriseDocumentRemoteDataSource remoteDataSource;

  EnterpriseDocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EnterpriseDocumentEntity>> uploadDocument({
    required String enterpriseId,
    String? sessionId,
    required String filePath,
    String? fileName,
    String documentType = 'evidence',
    void Function(int, int)? onProgress,
  }) async {
    try {
      final result = await remoteDataSource.uploadDocument(
        enterpriseId: enterpriseId,
        sessionId: sessionId,
        filePath: filePath,
        fileName: fileName,
        documentType: documentType,
        onProgress: onProgress,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getEnterpriseDocuments(String enterpriseId) async {
    try {
      final result = await remoteDataSource.getEnterpriseDocuments(enterpriseId);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getSessionDocuments(String sessionId) async {
    try {
      final result = await remoteDataSource.getSessionDocuments(sessionId);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      await remoteDataSource.deleteDocument(documentId);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
