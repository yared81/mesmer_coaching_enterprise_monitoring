import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

class LocalDatabase {
  static Database? _database;

  /// Returns null on web — SQLite is not supported in Chrome without sqflite_sw.js setup.
  /// All methods below guard against null and silently no-op on web.
  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('enterprise_monitoring.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE enterprises (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, data TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0, sync_last_updated TEXT)''');
    await db.execute('''CREATE TABLE coaching_sessions (
      id TEXT PRIMARY KEY, enterprise_id TEXT NOT NULL, data TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0, sync_last_updated TEXT)''');
    await db.execute('''CREATE TABLE phone_logs (
      id TEXT PRIMARY KEY, enterprise_id TEXT NOT NULL, data TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0, sync_last_updated TEXT)''');
    await db.execute('''CREATE TABLE trainings (
      id TEXT PRIMARY KEY, data TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0, sync_last_updated TEXT)''');
    await db.execute('''CREATE TABLE equipment (
      id TEXT PRIMARY KEY, enterprise_id TEXT NOT NULL, data TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0, sync_last_updated TEXT)''');
    await db.execute('''CREATE TABLE sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT, action_type TEXT NOT NULL,
      endpoint TEXT NOT NULL, payload TEXT NOT NULL, created_at TEXT NOT NULL,
      status INTEGER DEFAULT 0, error_message TEXT)''');
  }

  Future<void> clearAll() async {
    final db = await database;
    if (db == null) return;
    await db.delete('enterprises');
    await db.delete('coaching_sessions');
    await db.delete('phone_logs');
    await db.delete('trainings');
    await db.delete('equipment');
    await db.delete('sync_queue');
  }

  Future<void> enqueueSyncAction(String method, String endpoint, String jsonPayload) async {
    final db = await database;
    if (db == null) return; // no-op on web
    await db.insert('sync_queue', {
      'action_type': method,
      'endpoint': endpoint,
      'payload': jsonPayload,
      'created_at': DateTime.now().toIso8601String(),
      'status': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final db = await database;
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
    final db = await database;
    if (db == null) return;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markSyncActionFailed(int id, String errorMessage) async {
    final db = await database;
    if (db == null) return;
    await db.update('sync_queue', {'status': -1, 'error_message': errorMessage},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveEnterprise(String id, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return;
    await db.insert('enterprises', {
      'id': id,
      'name': data['business_name'] ?? 'Unknown',
      'data': jsonEncode(data),
      'sync_last_updated': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEnterprises() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('enterprises');
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getEnterpriseById(String id) async {
    final db = await database;
    if (db == null) return null;
    final maps = await db.query('enterprises', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
  }

  Future<void> saveSession(String id, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return;
    await db.insert('coaching_sessions', {
      'id': id,
      'enterprise_id': data['enterprise_id'] ?? 'Unknown',
      'data': jsonEncode(data),
      'sync_last_updated': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getSessionsByEnterprise(String enterpriseId) async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('coaching_sessions', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getSessionById(String id) async {
    final db = await database;
    if (db == null) return null;
    final maps = await db.query('coaching_sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
  }
}
