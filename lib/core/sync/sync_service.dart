import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'local_cache_repository.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(localCacheRepositoryProvider));
});

class SyncService {
  final LocalCacheRepository _cacheRepo;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._cacheRepo) {
    // Attempt to sync every 2 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      processQueue();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final actions = await _cacheRepo.getPendingSyncActions();
      if (actions.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (final action in actions) {
        final id = action['id'] as int;
        final type = action['action_type'] as String;
        final endpoint = action['endpoint'] as String;
        final payload = action['payload'] as Map<String, dynamic>;

        bool success = false;
        try {
          if (type == 'POST') {
            final uri = Uri.parse('\${ApiConstants.baseUrl}$endpoint');
            final response = await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload), // Needs proper auth headers in real app
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          } else if (type == 'PUT') {
            final uri = Uri.parse('\${ApiConstants.baseUrl}$endpoint');
            final response = await http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          }
        } catch (e) {
          // Network failed, keep in queue
          print('Sync failed for action $id: $e');
        }

        if (success) {
          await _cacheRepo.markSyncActionComplete(id);
        } else {
          // You could implement retry counts here
          await _cacheRepo.markSyncActionFailed(id, 'Network request failed');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
