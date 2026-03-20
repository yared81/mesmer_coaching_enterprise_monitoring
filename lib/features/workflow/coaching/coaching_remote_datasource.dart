import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'coaching_session_model.dart';
import 'phone_followup_model.dart';

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

  // --- Phone Follow-up methods ---
  Future<PhoneFollowupModel> createPhoneFollowup(PhoneFollowupModel model) async {
    final response = await _dio.post(
      ApiConstants.phoneFollowups,
      data: model.toJson(),
    );
    return PhoneFollowupModel.fromJson(response.data['data']);
  }

  Future<List<PhoneFollowupModel>> getCoachPhoneFollowups() async {
    final response = await _dio.get('${ApiConstants.phoneFollowups}/my-logs');
    final list = response.data['data'] as List;
    return list.map((json) => PhoneFollowupModel.fromJson(json)).toList();
  }

  Future<List<PhoneFollowupModel>> getEnterprisePhoneFollowups(String enterpriseId) async {
    final response = await _dio.get('${ApiConstants.phoneFollowups}/enterprise/$enterpriseId');
    final list = response.data['data'] as List;
    return list.map((json) => PhoneFollowupModel.fromJson(json)).toList();
  }
}
