import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/data/models/dashboard_stats_model.dart';

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
}
