enum OfflineOperationType {
  approveEvidence,
  rejectEvidence,
  visit,
  confirmProgress,
}

enum OfflineOperationStatus { pending, syncing, synchronized, failed }

class OfflineOperation {
  const OfflineOperation({
    required this.id,
    required this.type,
    required this.workId,
    required this.userId,
    required this.description,
    required this.payload,
    required this.createdAt,
    required this.status,
    this.syncAttempts = 0,
    this.lastError,
  });

  final String id;
  final OfflineOperationType type;
  final int workId;
  final int userId;
  final String description;
  final String payload;
  final DateTime createdAt;
  final OfflineOperationStatus status;
  final int syncAttempts;
  final String? lastError;

  OfflineOperation copyWith({
    OfflineOperationStatus? status,
    int? syncAttempts,
    String? lastError,
  }) => OfflineOperation(
    id: id,
    type: type,
    workId: workId,
    userId: userId,
    description: description,
    payload: payload,
    createdAt: createdAt,
    status: status ?? this.status,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    lastError: lastError,
  );
}
