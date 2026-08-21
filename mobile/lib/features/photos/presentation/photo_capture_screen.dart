import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../works/domain/work.dart';
import '../data/geolocator_location_service.dart';
import '../data/image_watermark_service.dart';
import '../data/local_image_validation_service.dart';
import '../data/local_photo_repository.dart';
import '../data/mock_photo_repository.dart';
import '../domain/image_validation_service.dart';
import '../domain/location_service.dart';
import '../domain/photo_evidence.dart';
import '../domain/watermark_service.dart';

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({
    required this.work,
    required this.stage,
    this.picker,
    this.locationService,
    this.watermarkService,
    this.initialType,
    this.validationService,
    this.photoRepository,
    super.key,
  });

  final Work work;
  final WorkStage stage;
  final ImagePicker? picker;
  final LocationService? locationService;
  final WatermarkService? watermarkService;
  final String? initialType;
  final ImageValidationService? validationService;
  final PhotoRepository? photoRepository;

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  late final LocationService _locationService =
      widget.locationService ?? GeolocatorLocationService();
  late final WatermarkService _watermarkService =
      widget.watermarkService ?? ImageWatermarkService();
  late final ImageValidationService _validationService =
      widget.validationService ?? LocalImageValidationService();
  late final PhotoRepository _photoRepository =
      widget.photoRepository ?? LocalPhotoRepository.instance;
  XFile? _photo;
  String? _watermarkedPath;
  CapturedLocation? _location;
  DateTime? _capturedAt;
  bool _openingCamera = false;
  bool _gettingLocation = false;
  bool _processingWatermark = false;
  String? _locationError;
  ValidatedImage? _validatedImage;
  String? _validationError;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? widget.stage.photoTypes.firstOrNull;
  }

  Future<void> _takePhoto() async {
    setState(() => _openingCamera = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
        maxWidth: 2048,
      );
      if (!mounted || photo == null) return;
      setState(() {
        _photo = photo;
        _capturedAt = DateTime.now();
        _location = null;
        _watermarkedPath = null;
        _locationError = null;
        _validatedImage = null;
        _validationError = null;
      });
      if (!await _validatePhoto(photo.path)) return;
      await _getLocation();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir la cámara.')),
      );
    } finally {
      if (mounted) setState(() => _openingCamera = false);
    }
  }

  Future<bool> _validatePhoto(String path) async {
    try {
      final validated = await _validationService.validate(path);
      if (await _photoRepository.containsHash(validated.sha256)) {
        throw const ImageValidationException(
          'Esta misma fotografía ya fue registrada en el dispositivo.',
        );
      }
      if (!mounted) return false;
      setState(() => _validatedImage = validated);
      return true;
    } on ImageValidationException catch (error) {
      if (!mounted) return false;
      setState(() => _validationError = error.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _gettingLocation = true;
      _locationError = null;
    });
    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _location = location);
      await _createWatermark();
    } on LocationException catch (error) {
      if (!mounted) return;
      setState(() => _locationError = error.message);
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _createWatermark() async {
    final photo = _photo;
    final location = _location;
    final capturedAt = _capturedAt;
    if (photo == null || location == null || capturedAt == null) return;
    setState(() => _processingWatermark = true);
    try {
      final path = await _watermarkService.createWatermarkedCopy(
        sourcePath: photo.path,
        data: WatermarkData(
          workFolio: widget.work.folio,
          capturedAt: capturedAt,
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
      if (!mounted) return;
      setState(() => _watermarkedPath = path);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _locationError = 'No fue posible generar la marca de agua.',
      );
    } finally {
      if (mounted) setState(() => _processingWatermark = false);
    }
  }

  void _save() {
    final photo = _photo;
    final location = _location;
    final capturedAt = _capturedAt;
    final watermarkedPath = _watermarkedPath;
    if (photo == null ||
        watermarkedPath == null ||
        _selectedType == null ||
        location == null ||
        capturedAt == null) {
      return;
    }
    Navigator.of(context).pop(
      PhotoEvidence(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        workId: widget.work.id,
        stageNumber: widget.stage.number,
        type: _selectedType!,
        capturedAt: capturedAt,
        latitude: location.latitude,
        longitude: location.longitude,
        locationAccuracy: location.accuracy,
        sha256: _validatedImage?.sha256,
        status: EvidenceStatus.pending,
        localPath: watermarkedPath,
        originalPath: photo.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Captura fotográfica'),
            Text(
              '${widget.work.folio} · ${widget.stage.name}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de fotografía',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.stage.photoTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    color: const Color(0xFFE7EDF6),
                    child: _photo == null
                        ? const _CameraPlaceholder()
                        : Image.file(
                            File(_watermarkedPath ?? _photo!.path),
                            key: const Key('capturedImage'),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_photo != null) ...[
                if (_validationError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _validationError!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                _MetadataPanel(
                  work: widget.work,
                  capturedAt: _capturedAt!,
                  location: _location,
                  isLoading: _gettingLocation,
                  error: _locationError,
                  onRetry: _getLocation,
                ),
                const SizedBox(height: 14),
                if (_processingWatermark)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Generando marca de agua…'),
                      ],
                    ),
                  ),
              ],
              if (_photo == null)
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    key: const Key('openCameraButton'),
                    onPressed: _openingCamera ? null : _takePhoto,
                    icon: _openingCamera
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                    label: const Text('Abrir cámara'),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('retakePhotoButton'),
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Repetir'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('savePhotoButton'),
                        onPressed: _watermarkedPath == null ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              const Text(
                'La fotografía se conservará localmente hasta conectarla con el servidor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataPanel extends StatelessWidget {
  const _MetadataPanel({
    required this.work,
    required this.capturedAt,
    required this.location,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final Work work;
  final DateTime capturedAt;
  final CapturedLocation? location;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final date =
        '${_twoDigits(capturedAt.day)}/${_twoDigits(capturedAt.month)}/${capturedAt.year}';
    final time =
        '${_twoDigits(capturedAt.hour)}:${_twoDigits(capturedAt.minute)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _MetadataRow(
            icon: Icons.apartment_rounded,
            label: 'Obra',
            value: work.folio,
          ),
          const SizedBox(height: 8),
          _MetadataRow(
            icon: Icons.schedule_rounded,
            label: 'Fecha y hora',
            value: '$date · $time',
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Row(
              children: [
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Obteniendo ubicación…'),
              ],
            )
          else if (location != null)
            _MetadataRow(
              icon: Icons.location_on_outlined,
              label: 'GPS',
              value:
                  '${location!.latitude.toStringAsFixed(6)}, ${location!.longitude.toStringAsFixed(6)} · ±${location!.accuracy.toStringAsFixed(0)} m',
              valueColor: AppColors.success,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error ?? 'Ubicación no disponible.',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
                TextButton(onPressed: onRetry, child: const Text('Reintentar')),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 21, color: AppColors.blue),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(color: AppColors.muted)),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_camera_outlined, size: 78, color: AppColors.muted),
          SizedBox(height: 14),
          Text(
            'Toma una fotografía de la obra',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'La galería del dispositivo no está habilitada.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
