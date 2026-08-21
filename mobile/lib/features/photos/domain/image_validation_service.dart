class ValidatedImage {
  const ValidatedImage({
    required this.sha256,
    required this.width,
    required this.height,
    required this.sizeBytes,
  });
  final String sha256;
  final int width;
  final int height;
  final int sizeBytes;
}

class ImageValidationException implements Exception {
  const ImageValidationException(this.message);
  final String message;
}

abstract interface class ImageValidationService {
  Future<ValidatedImage> validate(String path);
}
