import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/mock_photo_repository.dart';
import '../domain/photo_evidence.dart';

class PhotoDetailScreen extends StatefulWidget {
  const PhotoDetailScreen({
    required this.photo,
    required this.repository,
    super.key,
  });

  final PhotoEvidence photo;
  final PhotoRepository repository;

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PhotoEvidence _photo = widget.photo;
  bool _syncing = false;

  Future<void> _simulateSync() async {
    setState(() => _syncing = true);
    _photo = await widget.repository.updateSyncState(
      _photo,
      EvidenceStatus.uploading,
    );
    if (mounted) setState(() {});
    await Future<void>.delayed(const Duration(seconds: 1));
    _photo = await widget.repository.updateSyncState(
      _photo,
      EvidenceStatus.synchronized,
    );
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronización simulada completada.')),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: const Text(
          'Se eliminarán la fotografía original, la copia marcada y su registro local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.delete(_photo.id);
    for (final filePath in [_photo.localPath, _photo.originalPath]) {
      if (filePath == null) continue;
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = _photo.localPath != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text('Detalle de evidencia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: isLocal
                  ? Image.file(File(_photo.localPath!), fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFD8E9FF),
                      child: const Icon(
                        Icons.apartment_rounded,
                        size: 110,
                        color: AppColors.blue,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          _DetailCard(photo: _photo),
          const SizedBox(height: 18),
          if (_photo.status != EvidenceStatus.synchronized)
            FilledButton.icon(
              key: const Key('simulateSyncButton'),
              onPressed: _syncing ? null : _simulateSync,
              icon: _syncing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(
                _syncing ? 'Sincronizando…' : 'Simular sincronización',
              ),
            ),
          if (_photo.status == EvidenceStatus.pending ||
              _photo.status == EvidenceStatus.failed) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('deleteLocalPhotoButton'),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar captura local'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.photo});
  final PhotoEvidence photo;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        _row(Icons.category_outlined, 'Tipo', photo.type),
        const Divider(height: 26),
        _row(
          Icons.schedule_rounded,
          'Fecha',
          photo.capturedAt.toLocal().toString(),
        ),
        const Divider(height: 26),
        _row(
          Icons.location_on_outlined,
          'GPS',
          '${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}',
        ),
        const Divider(height: 26),
        _row(Icons.cloud_outlined, 'Estado', _label(photo.status)),
        if (photo.syncAttempts > 0) ...[
          const Divider(height: 26),
          _row(Icons.replay_rounded, 'Intentos', '${photo.syncAttempts}'),
        ],
      ],
    ),
  );

  Widget _row(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, color: AppColors.blue),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: const TextStyle(color: AppColors.muted)),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );

  String _label(EvidenceStatus status) => switch (status) {
    EvidenceStatus.pending => 'Pendiente',
    EvidenceStatus.uploading => 'Enviando',
    EvidenceStatus.synchronized => 'Sincronizada',
    EvidenceStatus.failed => 'Error',
  };
}
