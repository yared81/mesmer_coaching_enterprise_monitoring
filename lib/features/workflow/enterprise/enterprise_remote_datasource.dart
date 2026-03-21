import 'package:dio/dio.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';

class EnterpriseRemoteDatasource {
  EnterpriseRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> getEnterprises({
    String? search,
    String? sector,
    String? status,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/enterprises',
      queryParameters: {
        if (search != null) 'search': search,
        if (sector != null) 'sector': sector,
        if (status != null) 'status': status,
      },
    );
    
    final List<dynamic> data = response.data['enterprises'];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getEnterpriseById(String id) async {
    final response = await _dio.get('${ApiConstants.enterprises}/$id');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> createEnterprise(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.enterprises, data: data);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateEnterprise(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.enterprises}/$id', data: data);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getEnterpriseDashboardStats() async {
    final response = await _dio.get(ApiConstants.enterpriseDashboardStats);
    return response.data['data'];
  }

  Future<List<dynamic>> getEnterpriseTrends(String id) async {
    final response = await _dio.get('${ApiConstants.baseUrl}/enterprises/$id/trends');
    return response.data['data'];
  }
}
