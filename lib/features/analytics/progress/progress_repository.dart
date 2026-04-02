import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'progress_entity.dart';

abstract class ProgressRepository {
  Future<Either<Failure, ProgressEntity>> getEnterpriseProgress(
      String enterpriseId);
}
