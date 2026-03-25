import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'enterprise_document_entity.dart';

abstract class EnterpriseDocumentRepository {
  Future<Either<Failure, EnterpriseDocumentEntity>> uploadDocument({
    required String enterpriseId,
    String? sessionId,
    required String filePath,
    String? fileName,
    String documentType = 'evidence',
    void Function(int, int)? onProgress,
  });

  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getEnterpriseDocuments(String enterpriseId);
  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getSessionDocuments(String sessionId);
  Future<Either<Failure, void>> deleteDocument(String documentId);
}
