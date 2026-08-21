import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

import '../domain/image_validation_service.dart';

class LocalImageValidationService implements ImageValidationService {
  static const maxBytes = 10 * 1024 * 1024;
  static const minDimension = 720;

  @override
  Future<ValidatedImage> validate(String path) => Isolate.run(() {
    final file = File(path);
    if (!file.existsSync()) {
      throw const ImageValidationException('El archivo de imagen no existe.');
    }
    final bytes = file.readAsBytesSync();
    if (bytes.isEmpty) {
      throw const ImageValidationException('La fotografía está vacía.');
    }
    if (bytes.length > maxBytes) {
      throw const ImageValidationException(
        'La fotografía supera el límite de 10 MB.',
      );
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageValidationException(
        'El archivo no contiene una imagen válida.',
      );
    }
    if (decoded.width < minDimension || decoded.height < minDimension) {
      throw const ImageValidationException(
        'La fotografía debe medir al menos 720 × 720 píxeles.',
      );
    }
    return ValidatedImage(
      sha256: sha256.convert(bytes).toString(),
      width: decoded.width,
      height: decoded.height,
      sizeBytes: bytes.length,
    );
  });
}
