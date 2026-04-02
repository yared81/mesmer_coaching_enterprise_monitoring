import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'progress_entity.dart';
import 'progress_repository.dart';

// ── Repository implementation ─────────────────────────────────────────────────

class ProgressRepositoryImpl implements ProgressRepository {
  final dynamic _dio;
  ProgressRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, ProgressEntity>> getEnterpriseProgress(
      String enterpriseId) async {
    try {
      final response =
          await _dio.get('/enterprises/$enterpriseId/performance');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final current =
          data['current'] as Map<String, dynamic>? ?? {};
      final trends = (data['trends'] as List?) ?? [];

      final categoryScores = (current['category_scores'] ??
          current['categoryScores']) as Map<String, dynamic>? ??
          {};

      final indicators = <String, double>{};
      categoryScores.forEach((key, value) {
        final clean = key.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        final score = (value is Map)
            ? (value['score'] ?? value['average_score'] ?? 0.0)
            : value;
        indicators[clean] = (score as num).toDouble();
      });

      final baselineScore = (data['baseline']?['health_percentage'] ??
              data['baseline']?['healthPercentage'] ??
              0.0)
          .toDouble();
      final latestScore =
          (current['health_percentage'] ?? current['healthPercentage'] ?? 0.0)
              .toDouble();

      return Right(ProgressEntity(
        enterpriseId: enterpriseId,
        baselineScore: baselineScore,
        latestScore: latestScore,
        improvementPercentage: latestScore - baselineScore,
        indicators: indicators,
        trends: trends
            .map((t) => {
                  'date': t['date']?.toString() ?? '',
                  'score': (t['score'] as num?)?.toDouble() ?? 0.0,
                  'sessionTitle': t['sessionTitle']?.toString() ?? '',
                })
            .toList(),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(ref.watch(dioProvider));
});

final enterpriseProgressProvider =
    FutureProvider.family<ProgressEntity, String>((ref, enterpriseId) async {
  final repo = ref.watch(progressRepositoryProvider);
  final result = await repo.getEnterpriseProgress(enterpriseId);
  return result.fold((f) => throw f.message, (p) => p);
});
