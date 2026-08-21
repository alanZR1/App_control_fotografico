import 'package:flutter/material.dart';

import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../works/domain/work.dart';
import '../data/mock_photo_repository.dart';
import '../domain/photo_evidence.dart';
import 'photo_capture_screen.dart';
import 'photo_detail_screen.dart';

class EvidenceGalleryScreen extends StatefulWidget {
  const EvidenceGalleryScreen({
    required this.work,
    required this.stage,
    required this.repository,
    super.key,
  });

  final Work work;
  final WorkStage stage;
  final PhotoRepository repository;

  @override
  State<EvidenceGalleryScreen> createState() => _EvidenceGalleryScreenState();
}

class _EvidenceGalleryScreenState extends State<EvidenceGalleryScreen> {
  late final Future<List<PhotoEvidence>> _photosFuture;
  List<PhotoEvidence>? _photos;

  @override
  void initState() {
    super.initState();
    _photosFuture = widget.repository.getByStage(
      workId: widget.work.id,
      stageNumber: widget.stage.number,
    );
  }

  Future<void> _openCamera() async {
    final photo = await Navigator.of(context).push<PhotoEvidence>(
      MaterialPageRoute<PhotoEvidence>(
        builder: (_) => PhotoCaptureScreen(
          work: widget.work,
          stage: widget.stage,
          photoRepository: widget.repository,
        ),
      ),
    );
    if (!mounted || photo == null) return;
    await widget.repository.save(photo);
    if (!mounted) return;
    setState(() => _photos = [...?_photos, photo]);
  }

  Future<void> _reloadPhotos() async {
    final photos = await widget.repository.getByStage(
      workId: widget.work.id,
      stageNumber: widget.stage.number,
    );
    if (mounted) setState(() => _photos = photos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text('Evidencia fotográfica'),
      ),
      body: FutureBuilder<List<PhotoEvidence>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'No pudimos cargar las evidencias',
              message: 'Inténtalo nuevamente en unos momentos.',
            );
          }

          _photos ??= snapshot.data ?? const [];
          final photos = _photos!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _GalleryHeader(
                  work: widget.work,
                  stage: widget.stage,
                  photoCount: photos.length,
                ),
              ),
              if (photos.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.add_a_photo_outlined,
                    title: 'Aún no hay fotografías',
                    message: 'Agrega la primera evidencia de esta etapa.',
                    action: FilledButton.icon(
                      key: const Key('emptyAddPhotoButton'),
                      onPressed: _openCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Agregar fotografía'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) => _EvidenceCard(
                      photo: photos[index],
                      repository: widget.repository,
                      onReload: _reloadPhotos,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addPhotoButton'),
        onPressed: _openCamera,
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Agregar evidencia'),
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.work,
    required this.stage,
    required this.photoCount,
  });

  final Work work;
  final WorkStage stage;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              work.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${work.folio} · Etapa ${stage.number}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const Divider(height: 28),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.paleBlue,
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '$photoCount ${photoCount == 1 ? 'fotografía' : 'fotografías'} registrada${photoCount == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${stage.completed} / ${stage.total}',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
    required this.photo,
    required this.repository,
    required this.onReload,
  });

  final PhotoEvidence photo;
  final PhotoRepository repository;
  final Future<void> Function() onReload;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final date =
        '${_twoDigits(photo.capturedAt.day)}/${_twoDigits(photo.capturedAt.month)}/${photo.capturedAt.year}';
    final time =
        '${_twoDigits(photo.capturedAt.hour)}:${_twoDigits(photo.capturedAt.minute)}';

    return Material(
      key: Key(photo.id),
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x1A17345C),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) =>
                  PhotoDetailScreen(photo: photo, repository: repository),
            ),
          );
          await onReload();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB7D8FF), Color(0xFF477BB9)],
                  ),
                ),
                child: photo.localPath != null
                    ? Image.file(File(photo.localPath!), fit: BoxFit.cover)
                    : Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.apartment_rounded,
                              size: 70,
                              color: Color(0xCCFFFFFF),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xDFFFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_done_outlined,
                                size: 18,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$date · $time',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    switch (photo.status) {
                      EvidenceStatus.pending => 'Pendiente de sincronizar',
                      EvidenceStatus.uploading => 'Enviando…',
                      EvidenceStatus.synchronized => 'Sincronizada',
                      EvidenceStatus.failed => 'Error de sincronización',
                    },
                    style: TextStyle(
                      color: switch (photo.status) {
                        EvidenceStatus.pending => AppColors.warning,
                        EvidenceStatus.uploading => AppColors.blue,
                        EvidenceStatus.synchronized => AppColors.success,
                        EvidenceStatus.failed => AppColors.danger,
                      },
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
