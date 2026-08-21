import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../domain/offline_operation.dart';

class LocalOperationRepository {
  LocalOperationRepository._();
  static final instance = LocalOperationRepository._();

  Future<Database> get _db => LocalDatabase.instance;

  Future<OfflineOperation> enqueue({
    required OfflineOperationType type,
    required int workId,
    required int userId,
    required String description,
    Map<String, Object?> payload = const {},
  }) async {
    final now = DateTime.now();
    final operation = OfflineOperation(
      id: '${now.microsecondsSinceEpoch}-${type.name}',
      type: type,
      workId: workId,
      userId: userId,
      description: description,
      payload: jsonEncode(payload),
      createdAt: now,
      status: OfflineOperationStatus.pending,
    );
    await (await _db).insert('operaciones_pendientes', _toMap(operation));
    return operation;
  }

  Future<List<OfflineOperation>> getAll() async {
    final rows = await (await _db).query(
      'operaciones_pendientes',
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> delete(String id) async {
    await (await _db).delete(
      'operaciones_pendientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<OfflineOperation> updateStatus(
    OfflineOperation operation,
    OfflineOperationStatus status, {
    String? error,
  }) async {
    final updated = operation.copyWith(
      status: status,
      syncAttempts:
          operation.syncAttempts +
          (status == OfflineOperationStatus.syncing ? 1 : 0),
      lastError: error,
    );
    await (await _db).update(
      'operaciones_pendientes',
      _toMap(updated),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
    return updated;
  }

  Map<String, Object?> _toMap(OfflineOperation item) => {
    'id': item.id,
    'type': item.type.name,
    'work_id': item.workId,
    'user_id': item.userId,
    'description': item.description,
    'payload': item.payload,
    'created_at': item.createdAt.toIso8601String(),
    'status': item.status.name,
    'sync_attempts': item.syncAttempts,
    'last_error': item.lastError,
  };

  OfflineOperation _fromMap(Map<String, Object?> row) => OfflineOperation(
    id: row['id']! as String,
    type: OfflineOperationType.values.byName(row['type']! as String),
    workId: row['work_id']! as int,
    userId: row['user_id']! as int,
    description: row['description']! as String,
    payload: row['payload']! as String,
    createdAt: DateTime.parse(row['created_at']! as String),
    status: OfflineOperationStatus.values.byName(row['status']! as String),
    syncAttempts: row['sync_attempts']! as int,
    lastError: row['last_error'] as String?,
  );
}
