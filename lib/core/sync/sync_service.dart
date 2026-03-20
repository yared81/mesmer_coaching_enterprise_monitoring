import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/secure_storage.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'local_cache_repository.dart';

final syncStatusProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref,
    ref.watch(localCacheRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});

class SyncService {
  final Ref _ref;
  final LocalCacheRepository _cacheRepo;
  final SecureStorage _secureStorage;
  Timer? _syncTimer;
  bool _processing = false;

  SyncService(this._ref, this._cacheRepo, this._secureStorage) {
    // Attempt to sync every 2 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      processQueue();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> processQueue() async {
    if (_processing) return;
    _processing = true;
    _ref.read(syncStatusProvider.notifier).state = true;

    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        _processing = false;
        _ref.read(syncStatusProvider.notifier).state = false;
        return;
      }

      final actions = await _cacheRepo.getPendingSyncActions();
      if (actions.isEmpty) {
        _processing = false;
        _ref.read(syncStatusProvider.notifier).state = false;
        return;
      }

      for (final action in actions) {
        final id = action['id'] as int;
        final type = action['action_type'] as String;
        final endpoint = action['endpoint'] as String;
        final payload = action['payload'] as Map<String, dynamic>;

        bool success = false;
        try {
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          };

          if (type == 'POST') {
            final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
            final response = await http.post(
              uri,
              headers: headers,
              body: jsonEncode(payload),
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          } else if (type == 'PUT') {
            final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
            final response = await http.put(
              uri,
              headers: headers,
              body: jsonEncode(payload),
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          }
        } catch (e) {
          print('Sync failed for action $id: $e');
        }

        if (success) {
          await _cacheRepo.markSyncActionComplete(id);
        } else {
          await _cacheRepo.markSyncActionFailed(id, 'Network or Auth failure');
        }
      }
    } finally {
      _processing = false;
      _ref.read(syncStatusProvider.notifier).state = false;
    }
  }
}
