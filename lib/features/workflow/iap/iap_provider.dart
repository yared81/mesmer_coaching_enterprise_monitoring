import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
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

// ─── IAP Progress Stats ──────────────────────────────────────────────────────

class IapProgressStats {
  final String iapId;
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int percentage;

  const IapProgressStats({
    required this.iapId,
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.percentage,
  });

  factory IapProgressStats.fromJson(Map<String, dynamic> json) {
    return IapProgressStats(
      iapId: json['iap_id'],
      total: json['total'],
      completed: json['completed'],
      pending: json['pending'],
      overdue: json['overdue'],
      percentage: json['percentage'],
    );
  }
}

final iapProgressProvider =
    FutureProvider.family<IapProgressStats, String>((ref, iapId) async {
  final client = ref.watch(dioProvider);
  final response =
      await client.get('${ApiConstants.baseUrl}/iaps/$iapId/progress');
  return IapProgressStats.fromJson(response.data['data']);
});
