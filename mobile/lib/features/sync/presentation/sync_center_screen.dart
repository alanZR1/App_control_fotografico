import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/local_operation_repository.dart';
import '../domain/offline_operation.dart';

class SyncCenterScreen extends StatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  State<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends State<SyncCenterScreen> {
  final repository = LocalOperationRepository.instance;
  late Future<List<OfflineOperation>> operations = repository.getAll();
  bool syncing = false;

  void refresh() => setState(() => operations = repository.getAll());

  Future<void> simulateSync() async {
    setState(() => syncing = true);
    final items = await repository.getAll();
    for (var item in items.where(
      (item) => item.status != OfflineOperationStatus.synchronized,
    )) {
      item = await repository.updateStatus(
        item,
        OfflineOperationStatus.syncing,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await repository.updateStatus(item, OfflineOperationStatus.synchronized);
    }
    if (!mounted) return;
    setState(() {
      syncing = false;
      operations = repository.getAll();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sincronización local simulada completada.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.darkBlue,
      foregroundColor: Colors.white,
      title: const Text('Centro de sincronización'),
    ),
    body: FutureBuilder<List<OfflineOperation>>(
      future: operations,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Message(
            icon: Icons.error_outline,
            title: 'No se pudo abrir la cola local',
            action: refresh,
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const _Message(
            icon: Icons.cloud_done_outlined,
            title: 'No hay operaciones pendientes',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _OperationCard(
            operation: items[index],
            onDelete: () async {
              await repository.delete(items[index].id);
              refresh();
            },
          ),
        );
      },
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(18),
      child: FilledButton.icon(
        onPressed: syncing ? null : simulateSync,
        icon: syncing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync),
        label: Text(syncing ? 'Sincronizando…' : 'Simular sincronización'),
      ),
    ),
  );
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.operation, required this.onDelete});
  final OfflineOperation operation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (operation.status) {
      OfflineOperationStatus.pending => AppColors.warning,
      OfflineOperationStatus.syncing => AppColors.blue,
      OfflineOperationStatus.synchronized => AppColors.success,
      OfflineOperationStatus.failed => AppColors.danger,
    };
    return Card(
      child: ListTile(
        leading: Icon(_icon(operation.type), color: color),
        title: Text(operation.description),
        subtitle: Text(
          'Obra OB-${operation.workId.toString().padLeft(5, '0')} · ${_status(operation.status)}',
        ),
        trailing: operation.status == OfflineOperationStatus.synchronized
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : IconButton(
                tooltip: 'Eliminar de la cola',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
      ),
    );
  }

  IconData _icon(OfflineOperationType type) => switch (type) {
    OfflineOperationType.approveEvidence => Icons.check_circle_outline,
    OfflineOperationType.rejectEvidence => Icons.cancel_outlined,
    OfflineOperationType.visit => Icons.location_on_outlined,
    OfflineOperationType.confirmProgress => Icons.verified_outlined,
  };

  String _status(OfflineOperationStatus status) => switch (status) {
    OfflineOperationStatus.pending => 'Pendiente de sincronizar',
    OfflineOperationStatus.syncing => 'Sincronizando',
    OfflineOperationStatus.synchronized => 'Sincronizada',
    OfflineOperationStatus.failed => 'Error de sincronización',
  };
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: action, child: const Text('Reintentar')),
          ],
        ],
      ),
    ),
  );
}
