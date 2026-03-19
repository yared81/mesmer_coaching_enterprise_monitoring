import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'iap_entity.dart';
import 'iap_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

// --- Data Source ---
class IapRemoteDataSource {
  final Dio _client;
  IapRemoteDataSource(this._client);

  Future<List<IapModel>> getEnterpriseIaps(String enterpriseId) async {
    final response = await _client.get('${ApiConstants.baseUrl}/iaps/enterprise/$enterpriseId');
    final List data = response.data['data'] as List;
    return data.map((json) => IapModel.fromJson(json)).toList();
  }

  Future<IapModel> createIap(Map<String, dynamic> data) async {
    final response = await _client.post('${ApiConstants.baseUrl}/iaps', data: data);
    return IapModel.fromJson(response.data['data']);
  }

  Future<IapTaskModel> addTask(String iapId, Map<String, dynamic> data) async {
    final response = await _client.post('${ApiConstants.baseUrl}/iaps/$iapId/tasks', data: data);
    return IapTaskModel.fromJson(response.data['data']);
  }
}

// --- Providers ---
final iapDataSourceProvider = Provider<IapRemoteDataSource>((ref) {
  return IapRemoteDataSource(ref.watch(dioProvider));
});

final enterpriseIapsProvider = FutureProvider.family<List<IapEntity>, String>((ref, enterpriseId) async {
  try {
    final ds = ref.read(iapDataSourceProvider);
    final models = await ds.getEnterpriseIaps(enterpriseId);
    return models.map((e) => e.toEntity()).toList();
  } catch (e) {
    // Return empty list on failure for now to unblock UI dev
    return [];
  }
});
