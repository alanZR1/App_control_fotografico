class WatermarkData {
  const WatermarkData({
    required this.workFolio,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
  });

  final String workFolio;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
}

abstract interface class WatermarkService {
  Future<String> createWatermarkedCopy({
    required String sourcePath,
    required WatermarkData data,
  });
}
