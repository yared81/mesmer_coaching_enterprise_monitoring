import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/db/local_cache_repository.dart';
import 'training_entity.dart';
import 'training_model.dart';

abstract class TrainingRepository {
  Future<Either<Failure, List<TrainingEntity>>> getMyTrainings();
  Future<Either<Failure, TrainingEntity>> createTraining(TrainingEntity training);
  Future<Either<Failure, void>> updateAttendance(String trainingId, List<Map<String, dynamic>> attendanceData);
  Future<Either<Failure, int>> sendReminders(String trainingId);
}

class TrainingRepositoryImpl implements TrainingRepository {
  final Dio _dio;
  final LocalCacheRepository _cache;
  TrainingRepositoryImpl(this._dio, this._cache);

  @override
  Future<Either<Failure, List<TrainingEntity>>> getMyTrainings() async {
    try {
      final response = await _dio.get('/api/v1/trainings');
      final list = (response.data as List).map((j) => TrainingModel.fromJson(j)).toList();
      // Update cache
      await _cache.cacheTrainings(response.data as List<Map<String, dynamic>>);
      return Right(list);
    } on DioException catch (e) {
      // Try cache
      final cached = await _cache.getCachedTrainings();
      if (cached.isNotEmpty) {
        return Right(cached.map((j) => TrainingModel.fromJson(j)).toList());
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed and no cache available'));
    }
  }

  @override
  Future<Either<Failure, TrainingEntity>> createTraining(TrainingEntity training) async {
    final model = TrainingModel(
      id: training.id,
      title: training.title,
      description: training.description,
      trainerId: training.trainerId,
      date: training.date,
      location: training.location,
    );

    try {
      final response = await _dio.post('/api/v1/trainings', data: model.toJson());
      return Right(TrainingModel.fromJson(response.data));
    } on DioException catch (e) {
      // Offline -> Enqueue
      if (e.type != DioExceptionType.badResponse) {
        await _cache.enqueueSyncAction('POST', '/api/v1/trainings', model.toJson());
        return Right(training); // Treat as success in UI
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Creation failed'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAttendance(String trainingId, List<Map<String, dynamic>> attendanceData) async {
    try {
      await _dio.post('/api/v1/trainings/$trainingId/attendance', data: {'attendances': attendanceData});
      return const Right(null);
    } on DioException catch (e) {
      if (e.type != DioExceptionType.badResponse) {
        await _cache.enqueueSyncAction('POST', '/api/v1/trainings/$trainingId/attendance', {'attendances': attendanceData});
        return const Right(null);
      }
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Attendance sync failed'));
    }
  }

  @override
  Future<Either<Failure, int>> sendReminders(String trainingId) async {
    try {
      final response = await _dio.post('/api/v1/trainings/$trainingId/remind');
      return Right(response.data['count'] as int);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Reminder failed'));
    }
  }
}

