import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/diagnosis_template_entity.dart';

abstract class DiagnosisRepository {
  /// Fetches all templates for the institution
  Future<Either<Failure, List<DiagnosisTemplateEntity>>> listTemplates();

  /// Fetches the latest active diagnosis template for the institution
  Future<Either<Failure, DiagnosisTemplateEntity>> getLatestTemplate();

  /// Fetches a specific diagnosis template by ID
  Future<Either<Failure, DiagnosisTemplateEntity>> getTemplateById(String id);

  /// Creates a new template version
  Future<Either<Failure, DiagnosisTemplateEntity>> createTemplate(Map<String, dynamic> data);

  /// Updates an existing template directly
  Future<Either<Failure, DiagnosisTemplateEntity>> updateTemplate(String id, Map<String, dynamic> data);

  /// Deletes an existing template
  Future<Either<Failure, Unit>> deleteTemplate(String id);

  /// Fetches an existing diagnosis report for a session
  Future<Either<Failure, Map<String, dynamic>?>> getReportBySessionId(String sessionId);

  /// Submits a completed diagnosis for a specific session
  Future<Either<Failure, Map<String, dynamic>>> submitDiagnosis(
    String sessionId,
    String templateId,
    Map<String, String> responses, // questionId -> choiceId
  );

  /// Fetches performance data for an enterprise
  Future<Either<Failure, Map<String, dynamic>?>> getEnterprisePerformance(String enterpriseId);
}
