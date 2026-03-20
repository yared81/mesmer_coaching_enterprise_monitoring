import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('enterprise_monitoring.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Enterprises Cached Table
    await db.execute('''
      CREATE TABLE enterprises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_last_updated TEXT
      )
    ''');

    // 2. Coaching Sessions Cached Table
    await db.execute('''
      CREATE TABLE coaching_sessions (
        id TEXT PRIMARY KEY,
        enterprise_id TEXT NOT NULL,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_last_updated TEXT
      )
    ''');

    // 3. Phone Follow-ups Cached Table
    await db.execute('''
      CREATE TABLE phone_logs (
        id TEXT PRIMARY KEY,
        enterprise_id TEXT NOT NULL,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_last_updated TEXT
      )
    ''');

    // 4. Sync Queue Table
    // type: POST, PUT, DELETE
    // target: endpoint or entity
    // payload: JSON string of data
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status INTEGER DEFAULT 0,
        error_message TEXT
      )
    ''');
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('enterprises');
    await db.delete('coaching_sessions');
    await db.delete('phone_logs');
    await db.delete('sync_queue');
  }
}
