import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/data/models/coach_model.dart';

abstract class CoachRemoteDataSource {
  Future<List<CoachModel>> getCoaches();
  Future<CoachModel> getCoachDetails(String id);
  Future<CoachModel> registerCoach(String name, String email, String phone);
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  final Dio dio;

  CoachRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CoachModel>> getCoaches() async {
    try {
      final response = await dio.get('/coaches');
      final data = response.data['data'] as List;
      return data.map((e) => CoachModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Network error');
    } catch (e) {
      throw AppException('Failed to get coaches: $e');
    }
  }

  @override
  Future<CoachModel> getCoachDetails(String id) async {
    try {
      final response = await dio.get('/coaches/$id');
      return CoachModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Network error');
    } catch (e) {
      throw AppException('Failed to get coach details: $e');
    }
  }

  @override
  Future<CoachModel> registerCoach(String name, String email, String phone) async {
    try {
      final response = await dio.post('/coaches', data: {
        'name': name,
        'email': email,
        'phone': phone,
        // password is auto-handled by backend for the demo
      });
      return CoachModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException(e.response?.data?['message'] ?? e.message ?? 'Network error');
    } catch (e) {
      throw AppException('Failed to register coach: $e');
    }
  }
}

