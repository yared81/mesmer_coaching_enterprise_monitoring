import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database.dart';

final localCacheRepositoryProvider = Provider<LocalCacheRepository>((ref) {
  return LocalCacheRepository(ref.watch(localDatabaseProvider));
});

class LocalCacheRepository {
  final LocalDatabase _db;
  LocalCacheRepository(this._db);

  // --- Enterprises ---
  Future<void> cacheEnterprises(List<Map<String, dynamic>> enterprises) async {
    final db = await _db.database;
    if (db == null) return;
    final batch = db.batch();
    batch.delete('enterprises');
    for (final e in enterprises) {
      batch.insert('enterprises', {
        'id': e['id'] ?? e['_id'],
        'name': e['business_name'] ?? e['name'] ?? 'Unknown',
        'data': jsonEncode(e),
        'sync_status': 1,
        'sync_last_updated': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedEnterprises() async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('enterprises');
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  // --- Coaching Sessions ---
  Future<void> cacheEnterpriseSessions(String enterpriseId, List<Map<String, dynamic>> sessions) async {
    final db = await _db.database;
    if (db == null) return;
    final batch = db.batch();
    batch.delete('coaching_sessions', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    for (final s in sessions) {
      batch.insert('coaching_sessions', {
        'id': s['id'] ?? s['_id'],
        'enterprise_id': enterpriseId,
        'data': jsonEncode(s),
        'sync_status': 1,
        'sync_last_updated': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedEnterpriseSessions(String enterpriseId) async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('coaching_sessions', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  // --- Phone Follow-ups ---
  Future<void> cacheEnterprisePhoneLogs(String enterpriseId, List<Map<String, dynamic>> logs) async {
    final db = await _db.database;
    if (db == null) return;
    final batch = db.batch();
    batch.delete('phone_logs', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    for (final l in logs) {
      batch.insert('phone_logs', {
        'id': l['id'] ?? l['_id'],
        'enterprise_id': enterpriseId,
        'data': jsonEncode(l),
        'sync_status': 1,
        'sync_last_updated': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedEnterprisePhoneLogs(String enterpriseId) async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('phone_logs', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  // --- Training ---
  Future<void> cacheTrainings(List<Map<String, dynamic>> trainings) async {
    final db = await _db.database;
    if (db == null) return;
    final batch = db.batch();
    batch.delete('trainings');
    for (final t in trainings) {
      batch.insert('trainings', {
        'id': t['id'] ?? t['_id'],
        'data': jsonEncode(t),
        'sync_status': 1,
        'sync_last_updated': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedTrainings() async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('trainings');
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  // --- Equipment ---
  Future<void> cacheEnterpriseEquipment(String enterpriseId, List<Map<String, dynamic>> equipment) async {
    final db = await _db.database;
    if (db == null) return;
    final batch = db.batch();
    batch.delete('equipment', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    for (final e in equipment) {
      batch.insert('equipment', {
        'id': e['id'] ?? e['_id'],
        'enterprise_id': enterpriseId,
        'data': jsonEncode(e),
        'sync_status': 1,
        'sync_last_updated': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedEnterpriseEquipment(String enterpriseId) async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('equipment', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  // --- Offline Sync Queue ---
  Future<void> enqueueSyncAction(String actionType, String endpoint, Map<String, dynamic> payload) async {
    final db = await _db.database;
    if (db == null) return;
    await db.insert('sync_queue', {
      'action_type': actionType,
      'endpoint': endpoint,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
      'status': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final db = await _db.database;
    if (db == null) return [];
    final maps = await db.query('sync_queue', where: 'status = ?', whereArgs: [0], orderBy: 'id ASC');
    return maps.map((m) => {
      'id': m['id'],
      'action_type': m['action_type'],
      'endpoint': m['endpoint'],
      'payload': jsonDecode(m['payload'] as String),
      'created_at': m['created_at'],
    }).toList();
  }

  Future<void> markSyncActionComplete(int id) async {
    final db = await _db.database;
    if (db == null) return;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markSyncActionFailed(int id, String errorMessage) async {
    final db = await _db.database;
    if (db == null) return;
    await db.update('sync_queue', {'status': -1, 'error_message': errorMessage}, where: 'id = ?', whereArgs: [id]);
  }
}
