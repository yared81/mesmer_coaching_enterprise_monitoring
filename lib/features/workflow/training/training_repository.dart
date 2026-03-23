import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'training_entity.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TrainingRepository(dio);
});

class TrainingRepository {
  final Dio _dio;
  TrainingRepository(this._dio);

  Future<Either<Failure, List<TrainingEntity>>> getSessions() async {
    try {
      final response = await _dio.get('/trainings');
      final list = (response.data['data'] as List)
          .map((json) => TrainingEntity.fromJson(json))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, List<TrainingAttendanceEntity>>> getMyAttendance() async {
    try {
      final response = await _dio.get('/trainings/my-attendance');
      final list = (response.data['data'] as List)
          .map((json) => TrainingAttendanceEntity.fromJson(json))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, TrainingEntity>> getSessionById(String id) async {
    try {
      final response = await _dio.get('/trainings/$id');
      return Right(TrainingEntity.fromJson(response.data['data']));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, TrainingEntity>> createSession(TrainingEntity session) async {
    try {
      final response = await _dio.post('/trainings', data: session.toJson());
      return Right(TrainingEntity.fromJson(response.data['data']));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, TrainingEntity>> updateSession(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/trainings/$id', data: data);
      return Right(TrainingEntity.fromJson(response.data['data']));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, Unit>> deleteSession(String id) async {
    try {
      await _dio.delete('/trainings/$id');
      return Right(unit);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, Unit>> updateAttendance(String sessionId, List<Map<String, dynamic>> attendances) async {
    try {
      await _dio.post('/trainings/$sessionId/attendance', data: {'attendances': attendances});
      return Right(unit);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, int>> sendReminders(String sessionId) async {
    try {
      final response = await _dio.post('/trainings/$sessionId/remind');
      return Right(response.data['count'] ?? 0);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  Future<Either<Failure, TrainerStats>> getTrainerStats() async {
    try {
      final response = await _dio.get('/trainings/stats');
      return Right(TrainerStats.fromJson(response.data['data']));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}
