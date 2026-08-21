class CapturedLocation {
  const CapturedLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class LocationService {
  Future<CapturedLocation> getCurrentLocation();
}
