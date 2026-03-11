import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/dashboard/data/models/dashboard_stats_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSource(this._dio);

  Future<AdminStatsModel> getAdminStats() async {
    final response = await _dio.get('/api/v1/dashboard/admin');
    return AdminStatsModel.fromJson(response.data['data']['stats']);
  }

  Future<SupervisorStatsModel> getSupervisorStats() async {
    final response = await _dio.get('/api/v1/dashboard/supervisor');
    return SupervisorStatsModel.fromJson(response.data['data']['stats']);
  }
}
