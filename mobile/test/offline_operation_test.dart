import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_imagenes/features/sync/domain/offline_operation.dart';

void main() {
  test(
    'copyWith conserva el payload y actualiza el estado de sincronización',
    () {
      final operation = OfflineOperation(
        id: 'operation-1',
        type: OfflineOperationType.rejectEvidence,
        workId: 214,
        userId: 2,
        description: 'Evidencia rechazada',
        payload: '{"observation":"Imagen borrosa"}',
        createdAt: DateTime(2026, 8, 17),
        status: OfflineOperationStatus.pending,
      );

      final updated = operation.copyWith(
        status: OfflineOperationStatus.syncing,
        syncAttempts: 1,
      );

      expect(updated.status, OfflineOperationStatus.syncing);
      expect(updated.syncAttempts, 1);
      expect(updated.payload, operation.payload);
      expect(updated.workId, 214);
    },
  );
}
