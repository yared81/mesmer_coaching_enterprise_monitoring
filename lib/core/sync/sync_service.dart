import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/local_database.dart';
import '../providers/core_providers.dart';

final syncStatusProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(localDatabaseProvider),
    ref.watch(dioProvider),
    ref,
  );
});

class SyncService {
  final LocalDatabase _db;
  final Dio _dio;
  final Ref _ref;

  SyncService(this._db, this._dio, this._ref);

  Future<void> processQueue() async {
    // Alias for syncQueue to fix UI binding compilation error.
    return syncQueue();
  }

  Future<void> syncQueue() async {
    _ref.read(syncStatusProvider.notifier).state = true;
    
    try {
      final pendingActions = await _db.getPendingSyncActions();
    
    for (final action in pendingActions) {
      final id = action['id'] as int;
      final method = action['action_type'] as String;
      final endpoint = action['endpoint'] as String;
      final payload = action['payload'] as Map<String, dynamic>;

      try {
        if (method.toUpperCase() == 'POST') {
          await _dio.post(endpoint, data: payload);
        } else if (method.toUpperCase() == 'PUT') {
          await _dio.put(endpoint, data: payload);
        } else if (method.toUpperCase() == 'DELETE') {
          await _dio.delete(endpoint, data: payload);
        }
        
        await _db.markSyncActionComplete(id);
      } on DioException catch (e) {
        if (e.response != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
          // Client error typically means validation failed, we might want to flag it instead of retrying endlessly.
          await _db.markSyncActionFailed(id, e.response?.data?.toString() ?? e.message ?? 'Client Error');
        }
        // If 5xx or connection error, we leave it in the queue for the next sync cycle.
      } catch (e) {
        await _db.markSyncActionFailed(id, e.toString());
      }
    }
    } finally {
      _ref.read(syncStatusProvider.notifier).state = false;
    }
  }
}
