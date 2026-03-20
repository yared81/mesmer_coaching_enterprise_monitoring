import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class GraduationRepository {
  Future<Either<Failure, Map<String, dynamic>>> requestGraduation(String enterpriseId);
}

class GraduationRepositoryImpl implements GraduationRepository {
  final Dio _dio;
  GraduationRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestGraduation(String enterpriseId) async {
    try {
      final response = await _dio.post('/api/v1/graduation/$enterpriseId');
      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message'] ?? 'Graduation request failed'));
    }
  }
}
