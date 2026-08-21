import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

abstract final class LocalDatabase {
  static Database? _instance;
  static Future<Database>? _opening;

  static Future<Database> get instance {
    final database = _instance;
    if (database != null) return Future.value(database);
    return _opening ??= _open();
  }

  static Future<Database> _open() async {
    final databasePath = path.join(
      await getDatabasesPath(),
      'control_fotografico.db',
    );
    final database = await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, _) async {
        await _createEvidenceTable(db);
        await _createOperationsTable(db);
        await _seedEvidence(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE evidencias_locales ADD COLUMN sha256 TEXT',
          );
        }
        if (oldVersion < 3) await _createOperationsTable(db);
      },
    );
    _instance = database;
    return database;
  }

  static Future<void> _createEvidenceTable(Database db) => db.execute('''
    CREATE TABLE evidencias_locales (
      id TEXT PRIMARY KEY,
      work_id INTEGER NOT NULL,
      stage_number INTEGER NOT NULL,
      type TEXT NOT NULL,
      captured_at TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      accuracy REAL,
      status TEXT NOT NULL,
      local_path TEXT,
      original_path TEXT,
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_error TEXT,
      sha256 TEXT
    )
  ''');

  static Future<void> _createOperationsTable(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS operaciones_pendientes (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      work_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      description TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at TEXT NOT NULL,
      status TEXT NOT NULL,
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_error TEXT
    )
  ''');

  static Future<void> _seedEvidence(Database db) async {
    final capturedAt = DateTime(2026, 8, 10, 16, 28).toIso8601String();
    for (final item in [
      {'id': 'demo-214-1', 'type': 'Avance 25 %'},
      {'id': 'demo-214-2', 'type': 'Avance 50 %'},
    ]) {
      await db.insert('evidencias_locales', {
        'id': item['id'],
        'work_id': 214,
        'stage_number': 4,
        'type': item['type'],
        'captured_at': capturedAt,
        'latitude': 17.061234,
        'longitude': -96.719122,
        'accuracy': 8.0,
        'status': 'synchronized',
        'sync_attempts': 0,
      });
    }
  }
}
