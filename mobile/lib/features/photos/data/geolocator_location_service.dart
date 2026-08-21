import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/location_service.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<CapturedLocation> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Activa la ubicación del dispositivo para guardar la evidencia.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'El permiso de ubicación es necesario para guardar la evidencia.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'El permiso de ubicación está bloqueado. Habilítalo en Ajustes.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return CapturedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException {
      throw const LocationException(
        'No fue posible obtener la ubicación a tiempo. Inténtalo nuevamente.',
      );
    } catch (_) {
      throw const LocationException(
        'No fue posible determinar la ubicación actual.',
      );
    }
  }
}
