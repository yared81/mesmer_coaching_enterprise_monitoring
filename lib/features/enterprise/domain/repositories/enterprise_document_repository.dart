import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/enterprise_document_entity.dart';

abstract class EnterpriseDocumentRepository {
  Future<Either<Failure, EnterpriseDocumentEntity>> uploadDocument({
    required String enterpriseId,
    String? sessionId,
    required String fileName,
    required String fileUrl,
    String? fileType,
    String documentType = 'evidence',
  });

  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getEnterpriseDocuments(String enterpriseId);
  Future<Either<Failure, List<EnterpriseDocumentEntity>>> getSessionDocuments(String sessionId);
  Future<Either<Failure, void>> deleteDocument(String documentId);
}
