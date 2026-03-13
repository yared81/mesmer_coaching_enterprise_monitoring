import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/diagnosis_template_entity.dart';

abstract class DiagnosisRepository {
  /// Fetches the latest active diagnosis template for the institution
  Future<Either<Failure, DiagnosisTemplateEntity>> getLatestTemplate();

  /// Fetches an existing diagnosis report for a session
  Future<Either<Failure, Map<String, dynamic>?>> getReportBySessionId(String sessionId);

  /// Submits a completed diagnosis for a specific session
  Future<Either<Failure, Map<String, dynamic>>> submitDiagnosis({
    required String sessionId,
    required String templateId,
    required Map<String, String> responses, // questionId -> choiceId
  });
}
