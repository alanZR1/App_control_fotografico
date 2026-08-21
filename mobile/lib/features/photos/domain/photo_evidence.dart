enum EvidenceStatus { pending, uploading, synchronized, failed }

class PhotoEvidence {
  const PhotoEvidence({
    required this.id,
    required this.workId,
    required this.stageNumber,
    required this.type,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.localPath,
    this.originalPath,
    this.locationAccuracy,
    this.syncAttempts = 0,
    this.lastError,
    this.sha256,
  });

  final String id;
  final int workId;
  final int stageNumber;
  final String type;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
  final EvidenceStatus status;
  final String? localPath;
  final String? originalPath;
  final double? locationAccuracy;
  final int syncAttempts;
  final String? lastError;
  final String? sha256;

  PhotoEvidence copyWith({
    EvidenceStatus? status,
    int? syncAttempts,
    String? lastError,
  }) => PhotoEvidence(
    id: id,
    workId: workId,
    stageNumber: stageNumber,
    type: type,
    capturedAt: capturedAt,
    latitude: latitude,
    longitude: longitude,
    status: status ?? this.status,
    localPath: localPath,
    originalPath: originalPath,
    locationAccuracy: locationAccuracy,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    lastError: lastError,
    sha256: sha256,
  );
}
