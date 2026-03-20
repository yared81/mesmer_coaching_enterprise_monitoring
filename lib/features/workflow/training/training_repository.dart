import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
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
  TrainingRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<TrainingEntity>>> getMyTrainings() async {
    try {
      final response = await _dio.get('/api/v1/trainings');
      final list = (response.data as List).map((j) => TrainingModel.fromJson(j)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Fetch failed'));
    }
  }

  @override
  Future<Either<Failure, TrainingEntity>> createTraining(TrainingEntity training) async {
    try {
      final model = TrainingModel(
        id: training.id,
        title: training.title,
        description: training.description,
        trainerId: training.trainerId,
        date: training.date,
        location: training.location,
      );
      final response = await _dio.post('/api/v1/trainings', data: model.toJson());
      return Right(TrainingModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Creation failed'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAttendance(String trainingId, List<Map<String, dynamic>> attendanceData) async {
    try {
      await _dio.post('/api/v1/trainings/$trainingId/attendance', data: {'attendances': attendanceData});
      return const Right(null);
    } on DioException catch (e) {
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
