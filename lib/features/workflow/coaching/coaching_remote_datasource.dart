import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'coaching_session_model.dart';

class CoachingRemoteDataSource {
  final Dio _dio;

  CoachingRemoteDataSource(this._dio);

  Future<CoachingSessionModel> createSession(CoachingSessionModel session) async {
    final response = await _dio.post(
      ApiConstants.sessions,
      data: session.toJson(),
    );
    return CoachingSessionModel.fromJson(response.data['data']);
  }

  Future<List<CoachingSessionModel>> getMySessions() async {
    final response = await _dio.get('${ApiConstants.sessions}/my-sessions');
    final list = response.data['data'] as List;
    return list.map((json) => CoachingSessionModel.fromJson(json)).toList();
  }

  Future<List<CoachingSessionModel>> getEnterpriseSessions(String enterpriseId) async {
    final response = await _dio.get('${ApiConstants.sessions}/enterprise/$enterpriseId');
    final list = response.data['data'] as List;
    return list.map((json) => CoachingSessionModel.fromJson(json)).toList();
  }

  Future<CoachingSessionModel> updateSession(CoachingSessionModel session) async {
    final response = await _dio.put(
      '${ApiConstants.sessions}/${session.id}',
      data: session.toJson(),
    );
    return CoachingSessionModel.fromJson(response.data['data']);
  }
}
