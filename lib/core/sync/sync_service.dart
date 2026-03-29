import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/db/local_database.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_provider.dart';

final syncStatusProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref,
    ref.watch(localDatabaseProvider),
    ref.watch(dioProvider),
  );
});

class SyncService {
  final Ref _ref;
  final LocalDatabase _db;
  final Dio _dio;
  Timer? _syncTimer;
  bool _processing = false;

  SyncService(this._ref, this._db, this._dio) {
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
      final actions = await _db.getPendingSyncActions();
      if (actions.isEmpty) {
        _processing = false;
        _ref.read(syncStatusProvider.notifier).state = false;
        return;
      }

      bool syncOccurred = false;

      for (final action in actions) {
        final id = action['id'] as int;
        final type = action['action_type'] as String;
        final endpoint = action['endpoint'] as String;
        final payload = action['payload'] as Map<String, dynamic>;

        bool success = false;
        try {
          if (type == 'POST') {
            final response = await _dio.post(
              endpoint,
              data: payload,
            );
            if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
              success = true;
            }
          } else if (type == 'PUT') {
            final response = await _dio.put(
              endpoint,
              data: payload,
            );
            if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
              success = true;
            }
          }
        } catch (e) {
          print('Sync failed for action $id: $e');
        }

        if (success) {
          await _db.markSyncActionComplete(id);
          syncOccurred = true;
        } else {
          await _db.markSyncActionFailed(id, 'Network or Auth failure');
        }
      }

      if (syncOccurred) {
        // Force refresh all session lists so ghost IDs are replaced
        _ref.invalidate(coachingSessionsProvider);
        _ref.invalidate(enterpriseSessionsProvider);
        _ref.invalidate(phoneFollowupListProvider);
        _ref.invalidate(enterprisePhoneFollowupsProvider);
      }
    } finally {
      _processing = false;
      _ref.read(syncStatusProvider.notifier).state = false;
    }
  }
}
