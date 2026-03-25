import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'consent_record_entity.dart';

abstract class ConsentRepository {
  Future<Either<Failure, ConsentRecordEntity>> createConsent(Map<String, dynamic> data);
  Future<Either<Failure, ConsentRecordEntity?>> getConsentByEnterprise(String enterpriseId);
  Future<Either<Failure, List<ConsentRecordEntity>>> listConsents();
}
