import 'dart:math' as math;

/// Geographic bearing is measured clockwise from TRUE NORTH; it does not use
/// device heading and must not be represented as turn-by-turn navigation.
class FieldNavigation {
  const FieldNavigation._();

  static double _radians(double degrees) => degrees * math.pi / 180;

  static void _validate(double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite ||
        latitude < -90 || latitude > 90 ||
        longitude < -180 || longitude > 180) {
      throw const FormatException('Invalid geographic coordinate');
    }
  }

  static NavigationLeg between({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    _validate(fromLatitude, fromLongitude);
    _validate(toLatitude, toLongitude);

    const radiusMeters = 6371008.8;
    final lat1 = _radians(fromLatitude);
    final lat2 = _radians(toLatitude);
    final latDiff = lat2 - lat1;
    // Wrap longitude difference for the international date line.
    final rawLonDiff = _radians(toLongitude - fromLongitude);
    final lonDiff = math.atan2(math.sin(rawLonDiff), math.cos(rawLonDiff));

    final haversine = math.pow(math.sin(latDiff / 2), 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.pow(math.sin(lonDiff / 2), 2);
    final safeHaversine = (haversine as num).toDouble().clamp(0.0, 1.0);
    final distanceMeters = 2 * radiusMeters *
        math.atan2(math.sqrt(safeHaversine), math.sqrt(1 - safeHaversine));

    final y = math.sin(lonDiff) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lonDiff);
    final bearing = distanceMeters < 0.05
        ? 0.0
        : (math.atan2(y, x) * 180 / math.pi + 360) % 360;

    return NavigationLeg(
      distanceMeters: distanceMeters,
      bearingDegrees: bearing,
    );
  }
}

class NavigationLeg {
  const NavigationLeg({
    required this.distanceMeters,
    required this.bearingDegrees,
  });

  final double distanceMeters;
  final double bearingDegrees;

  String cardinal(bool english) {
    const fr = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSO', 'SO', 'OSO', 'O', 'ONO', 'NO', 'NNO',
    ];
    const en = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((bearingDegrees / 22.5).round()) % 16;
    return (english ? en : fr)[index];
  }

  String distanceLabel(bool english) {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }
}
