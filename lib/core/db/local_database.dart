import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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

    // Check if the database exists
    final exists = await databaseExists(path);

    if (!exists) {
      print("Creating local database from bundled asset...");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      try {
        // Load database from asset and copy
        ByteData data = await rootBundle.load(join("assets/db", "mesmer.sqlite"));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied successfully");
      } catch (e) {
        print("Failed to copy database from asset: $e");
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _onOpenDB,
    );
  }

  Future<void> _onOpenDB(Database db) async {
    // Adapter to convert raw backend schema into caching schema if needed
    final columns = await db.rawQuery("PRAGMA table_info('enterprises')");
    final isBackendSchema = columns.isNotEmpty && !columns.any((c) => c['name'] == 'data');

    if (isBackendSchema) {
      print("Adapting backend schema to local caching schema...");
      // Adapt Enterprises
      await db.execute('ALTER TABLE enterprises RENAME TO backend_enterprises');
      await db.execute('''
        CREATE TABLE enterprises (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          data TEXT NOT NULL,
          sync_status INTEGER DEFAULT 0,
          sync_last_updated TEXT
        )
      ''');
      final oldEnt = await db.query('backend_enterprises');
      for (var row in oldEnt) {
        await db.insert('enterprises', {
          'id': row['id']?.toString() ?? '',
          'name': row['business_name']?.toString() ?? 'Unknown',
          'data': jsonEncode(row),
        });
      }
      await db.execute('DROP TABLE backend_enterprises');

      // Adapt Sessions
      final sessionCols = await db.rawQuery("PRAGMA table_info('coaching_sessions')");
      if (sessionCols.isNotEmpty && !sessionCols.any((c) => c['name'] == 'data')) {
        await db.execute('ALTER TABLE coaching_sessions RENAME TO backend_sessions');
        await db.execute('''
          CREATE TABLE coaching_sessions (
            id TEXT PRIMARY KEY,
            enterprise_id TEXT NOT NULL,
            data TEXT NOT NULL,
            sync_status INTEGER DEFAULT 0,
            sync_last_updated TEXT
          )
        ''');
        final oldSessions = await db.query('backend_sessions');
        for (var row in oldSessions) {
          await db.insert('coaching_sessions', {
            'id': row['id']?.toString() ?? '',
            'enterprise_id': row['enterprise_id']?.toString() ?? '',
            'data': jsonEncode(row),
          });
        }
        await db.execute('DROP TABLE backend_sessions');
      }

      // Ensure supporting tables exist
      await _createDB(db, 1);
    }
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

    // 4. Training Cached Table
    await db.execute('''
      CREATE TABLE trainings (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_last_updated TEXT
      )
    ''');

    // 5. Equipment Cached Table
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        enterprise_id TEXT NOT NULL,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        sync_last_updated TEXT
      )
    ''');

    // 6. Sync Queue Table
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
    await db.delete('trainings');
    await db.delete('equipment');
    await db.delete('sync_queue');
  }

  Future<void> enqueueSyncAction(String method, String endpoint, String jsonPayload) async {
    final db = await database;
    
    // As per hackathon minimum requirements, inject local timestamp
    // Device ID would ideally go here, using physical device lookup, but for now we append an offline flag
    await db.insert(
      'sync_queue',
      {
        'action_type': method,
        'endpoint': endpoint,
        'payload': jsonPayload,
        'created_at': DateTime.now().toIso8601String(),
        'status': 0, // 0 = pending
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final db = await database;
    final maps = await db.query(
      'sync_queue', 
      where: 'status = ?', 
      whereArgs: [0], 
      orderBy: 'id ASC'
    );
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
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markSyncActionFailed(int id, String errorMessage) async {
    final db = await database;
    await db.update(
      'sync_queue', 
      {'status': -1, 'error_message': errorMessage}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // --- Enterprise Methods ---
  
  Future<void> saveEnterprise(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'enterprises',
      {
        'id': id,
        'name': data['business_name'] ?? 'Unknown',
        'data': jsonEncode(data),
        'sync_last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getEnterprises() async {
    final db = await database;
    final maps = await db.query('enterprises');
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getEnterpriseById(String id) async {
    final db = await database;
    final maps = await db.query('enterprises', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
  }

  // --- Session Methods ---

  Future<void> saveSession(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'coaching_sessions',
      {
        'id': id,
        'enterprise_id': data['enterprise_id'] ?? 'Unknown',
        'data': jsonEncode(data),
        'sync_last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSessionsByEnterprise(String enterpriseId) async {
    final db = await database;
    final maps = await db.query('coaching_sessions', where: 'enterprise_id = ?', whereArgs: [enterpriseId]);
    return maps.map((m) => jsonDecode(m['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getSessionById(String id) async {
    final db = await database;
    final maps = await db.query('coaching_sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
  }
}
