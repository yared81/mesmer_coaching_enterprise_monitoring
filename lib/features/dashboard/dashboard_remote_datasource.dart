import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_stats_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSource(this._dio);

  Future<AdminStatsModel> getAdminStats() async {
    final response = await _dio.get(ApiConstants.adminStats);
    return AdminStatsModel.fromJson(response.data['data']);
  }

  Future<SupervisorStatsModel> getSupervisorStats() async {
    final response = await _dio.get(ApiConstants.supervisorStats);
    return SupervisorStatsModel.fromJson(response.data['data']);
  }

  Future<CoachStatsModel> getCoachStats() async {
    final response = await _dio.get(ApiConstants.coachStats);
    return CoachStatsModel.fromJson(response.data['data']);
  }

  Future<CoachStatsModel> getCoachStatsById(String id) async {
    final response = await _dio.get(ApiConstants.coachStatsById(id));
    return CoachStatsModel.fromJson(response.data['data']);
  }

  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get('notifications');
    return response.data['data'];
  }

  Future<MeStatsModel> getMeStats() async {
    final response = await _dio.get('${ApiConstants.dashboard}/me');
    return MeStatsModel.fromJson(response.data);
  }
}
