import '../domain/photo_evidence.dart';

abstract interface class PhotoRepository {
  Future<List<PhotoEvidence>> getByStage({
    required int workId,
    required int stageNumber,
  });
  Future<void> save(PhotoEvidence evidence);
  Future<void> delete(String id);
  Future<bool> containsHash(String sha256);
  Future<PhotoEvidence> updateSyncState(
    PhotoEvidence evidence,
    EvidenceStatus status, {
    String? error,
  });
}

class MockPhotoRepository implements PhotoRepository {
  final List<PhotoEvidence> _localEvidence = [];
  @override
  Future<List<PhotoEvidence>> getByStage({
    required int workId,
    required int stageNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [..._evidence, ..._localEvidence]
        .where(
          (photo) => photo.workId == workId && photo.stageNumber == stageNumber,
        )
        .toList();
  }

  @override
  Future<void> save(PhotoEvidence evidence) async =>
      _localEvidence.add(evidence);

  @override
  Future<void> delete(String id) async =>
      _localEvidence.removeWhere((item) => item.id == id);

  @override
  Future<bool> containsHash(String sha256) async =>
      _localEvidence.any((item) => item.sha256 == sha256);

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
    final index = _localEvidence.indexWhere((item) => item.id == evidence.id);
    if (index >= 0) _localEvidence[index] = updated;
    return updated;
  }

  static final _evidence = [
    PhotoEvidence(
      id: 'foto-214-1',
      workId: 214,
      stageNumber: 4,
      type: 'Avance 25 %',
      capturedAt: DateTime(2026, 8, 8, 10, 12),
      latitude: 17.061234,
      longitude: -96.719122,
      status: EvidenceStatus.synchronized,
    ),
    PhotoEvidence(
      id: 'foto-214-2',
      workId: 214,
      stageNumber: 4,
      type: 'Avance 50 %',
      capturedAt: DateTime(2026, 8, 10, 16, 28),
      latitude: 17.061234,
      longitude: -96.719122,
      status: EvidenceStatus.synchronized,
    ),
  ];
}
