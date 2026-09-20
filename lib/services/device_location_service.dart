import 'package:geolocator/geolocator.dart';

enum DeviceLocationFailure {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class DeviceLocationResult {
  const DeviceLocationResult._({
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.failure,
  });

  const DeviceLocationResult.success({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) : this._(
          latitude: latitude,
          longitude: longitude,
          accuracyMeters: accuracyMeters,
        );

  const DeviceLocationResult.failure(DeviceLocationFailure failure)
      : this._(failure: failure);

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DeviceLocationFailure? failure;

  bool get isSuccess =>
      failure == null && latitude != null && longitude != null;
}

/// Foreground-only device location.
///
/// ReadySafe requests permission only after an explicit user action. It does
/// not subscribe to position streams and does not store a location history.
class DeviceLocationService {
  const DeviceLocationService();

  Future<DeviceLocationResult> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeviceLocationResult.failure(
          DeviceLocationFailure.servicesDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult.failure(
          DeviceLocationFailure.permissionDeniedForever,
        );
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const DeviceLocationResult.failure(
          DeviceLocationFailure.permissionDenied,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return DeviceLocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } catch (_) {
      return const DeviceLocationResult.failure(
        DeviceLocationFailure.unavailable,
      );
    }
  }

  Future<bool> openSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
