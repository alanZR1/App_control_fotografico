import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../domain/photo_evidence.dart';
import 'mock_photo_repository.dart';

class LocalPhotoRepository implements PhotoRepository {
  LocalPhotoRepository._();
  static final instance = LocalPhotoRepository._();

  Future<Database> get _db => LocalDatabase.instance;

  @override
  Future<List<PhotoEvidence>> getByStage({
    required int workId,
    required int stageNumber,
  }) async {
    final rows = await (await _db).query(
      'evidencias_locales',
      where: 'work_id = ? AND stage_number = ?',
      whereArgs: [workId, stageNumber],
      orderBy: 'captured_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<void> save(PhotoEvidence evidence) async {
    await (await _db).insert(
      'evidencias_locales',
      _toMap(evidence),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    await (await _db).delete(
      'evidencias_locales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> containsHash(String sha256) async {
    final result = await (await _db).query(
      'evidencias_locales',
      columns: ['id'],
      where: 'sha256 = ?',
      whereArgs: [sha256],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<PhotoEvidence> updateSyncState(
    PhotoEvidence evidence,
    EvidenceStatus status, {
    String? error,
  }) async {
    final updated = evidence.copyWith(
      status: status,
      syncAttempts: evidence.syncAttempts + 1,
      lastError: error,
    );
    await save(updated);
    return updated;
  }

  Map<String, Object?> _toMap(PhotoEvidence item) => {
    'id': item.id,
    'work_id': item.workId,
    'stage_number': item.stageNumber,
    'type': item.type,
    'captured_at': item.capturedAt.toIso8601String(),
    'latitude': item.latitude,
    'longitude': item.longitude,
    'accuracy': item.locationAccuracy,
    'status': item.status.name,
    'local_path': item.localPath,
    'original_path': item.originalPath,
    'sync_attempts': item.syncAttempts,
    'last_error': item.lastError,
    'sha256': item.sha256,
  };

  PhotoEvidence _fromMap(Map<String, Object?> row) => PhotoEvidence(
    id: row['id']! as String,
    workId: row['work_id']! as int,
    stageNumber: row['stage_number']! as int,
    type: row['type']! as String,
    capturedAt: DateTime.parse(row['captured_at']! as String),
    latitude: (row['latitude']! as num).toDouble(),
    longitude: (row['longitude']! as num).toDouble(),
    locationAccuracy: (row['accuracy'] as num?)?.toDouble(),
    status: EvidenceStatus.values.byName(row['status']! as String),
    localPath: row['local_path'] as String?,
    originalPath: row['original_path'] as String?,
    syncAttempts: row['sync_attempts']! as int,
    lastError: row['last_error'] as String?,
    sha256: row['sha256'] as String?,
  );
}
