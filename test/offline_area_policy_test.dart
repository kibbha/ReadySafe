import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/offline_area_service.dart';

void main() {
  group('OpenFreeMap small-area policy', () {
    test('Geneva area stays far below the tile budget', () {
      final area = OfflineAreaPolicy.around(46.2044, 6.1432);
      expect(area.estimatedTiles, greaterThan(0));
      expect(area.estimatedTiles, lessThanOrEqualTo(OfflineAreaPolicy.maxTiles));
      expect(OfflineAreaPolicy.radiusKm, 1.5);
      expect(OfflineAreaPolicy.minZoom, 11);
      expect(OfflineAreaPolicy.maxZoom, 15);
      expect(OfflineAreaPolicy.maxConcurrentRequests, 4);
      expect(OfflineAreaPolicy.maxBytes, 50 * 1024 * 1024);
    });

    test('tile estimate counts each zoom level and scales with area', () {
      const lat = 46.20;
      const lon = 6.14;
      final small = OfflineAreaPolicy.estimatedTileCount(
        lat - 0.001, lon - 0.001, lat + 0.001, lon + 0.001,
      );
      final large = OfflineAreaPolicy.estimatedTileCount(
        lat - 0.025, lon - 0.025, lat + 0.025, lon + 0.025,
      );
      expect(small, greaterThan(0));
      expect(large, greaterThan(small));
    });

    test('rejects non-finite, invalid or wraparound coordinates', () {
      expect(() => OfflineAreaPolicy.around(double.nan, 7), throwsFormatException);
      expect(() => OfflineAreaPolicy.around(90, 7), throwsFormatException);
      expect(() => OfflineAreaPolicy.around(45, 180), throwsFormatException);
      expect(
        () => OfflineAreaPolicy.estimatedTileCount(46, 7, 45, 8),
        throwsFormatException,
      );
    });

    test('does not mistake a country-wide rectangle for a permitted area', () {
      final tiles = OfflineAreaPolicy.estimatedTileCount(45.8, 5.8, 47.8, 10.5);
      expect(tiles, greaterThan(OfflineAreaPolicy.maxTiles));
    });
  });
}
