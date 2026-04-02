import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'report_entity.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportEntity>> getAggregatedStats();
}
