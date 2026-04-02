import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'report_entity.dart';
import 'reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final dynamic _dio;
  ReportsRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, ReportEntity>> getAggregatedStats() async {
    try {
      final response = await _dio.get('/analytics/aggregated');
      return Right(ReportEntity.fromJson(
          response.data['data'] as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(dioProvider));
});

final reportStatsProvider = FutureProvider<ReportEntity>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.getAggregatedStats();
  return result.fold((f) => throw f.message, (r) => r);
});
