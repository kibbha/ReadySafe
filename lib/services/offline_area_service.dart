import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;

/// Small-area download policy for OpenFreeMap.
///
/// Larger, country-wide maps must use separately licensed regional packs.
/// This policy is intentionally conservative to avoid uncontrolled tile scraping.
class OfflineAreaPolicy {
  const OfflineAreaPolicy._();

  static const styleUrl = 'https://tiles.openfreemap.org/styles/liberty';
  static const attribution = 'OpenFreeMap © OpenMapTiles · © OpenStreetMap contributors';
  static const radiusKm = 1.5;
  static const minZoom = 11;
  static const maxZoom = 15;
  static const maxTiles = 3000;
  static const maxBytes = 50 * 1024 * 1024;
  static const maxConcurrentRequests = 4;

  static OfflineAreaDraft around(double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite ||
        latitude < -80 || latitude > 80 ||
        longitude < -179.9 || longitude > 179.9) {
      throw const FormatException('Unsupported map centre');
    }

    final latDelta = radiusKm / 111.32;
    final lonDelta = radiusKm / (111.32 * math.cos(latitude * math.pi / 180));

    final south = latitude - latDelta;
    final north = latitude + latDelta;
    final west = longitude - lonDelta;
    final east = longitude + lonDelta;

    if (south < -85 || north > 85 || west < -180 || east > 180) {
      throw const FormatException('Map area crosses a supported boundary');
    }

    final tiles = estimatedTileCount(south, west, north, east);
    if (tiles < 1 || tiles > maxTiles) {
      throw FormatException('Area exceeds tile policy ($tiles > $maxTiles)');
    }

    return OfflineAreaDraft(
      latitude: latitude,
      longitude: longitude,
      bounds: maplibre.LatLngBounds(
        southwest: maplibre.LatLng(south, west),
        northeast: maplibre.LatLng(north, east),
      ),
      estimatedTiles: tiles,
    );
  }

  /// Conservative number of slippy-map x/y tile cells at every zoom.
  /// This estimate is a preflight guard, NOT a byte-size guarantee.
  static int estimatedTileCount(
    double south, double west, double north, double east,
  ) {
    if (south >= north || west >= east ||
        south < -85 || north > 85 || west < -180 || east > 180) {
      throw const FormatException('Invalid tile bounds');
    }

    int total = 0;
    for (var zoom = minZoom; zoom <= maxZoom; zoom++) {
      final n = 1 << zoom;
      int x(double lon) => ((lon + 180) / 360 * n)
          .floor().clamp(0, n - 1).toInt();
      int y(double lat) {
        final radians = lat * math.pi / 180;
        return ((1 - math.log(math.tan(radians) +
                    1 / math.cos(radians)) / math.pi) / 2 * n)
            .floor().clamp(0, n - 1).toInt();
      }

      final across = x(east) - x(west) + 1;
      final down = y(south) - y(north) + 1;
      total += across * down;
    }
    return total;
  }
}

class OfflineAreaDraft {
  const OfflineAreaDraft({
    required this.latitude,
    required this.longitude,
    required this.bounds,
    required this.estimatedTiles,
  });

  final double latitude;
  final double longitude;
  final maplibre.LatLngBounds bounds;
  final int estimatedTiles;

  String get label =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}

class OfflineAreaRecord {
  const OfflineAreaRecord(this.region, this.status);

  final maplibre.OfflineRegion region;
  final maplibre.OfflineRegionStatus? status;

  bool get complete => status?.isComplete == true;

  String get label =>
      region.metadata['name'] is String
          ? region.metadata['name'] as String
          : 'Zone ${region.id}';
}

class OfflineAreaService {
  const OfflineAreaService();

  static const owner = 'readysafe-v4-area';

  /// MapLibre owns the SQLite tile cache on the device; list only our areas.
  Future<List<OfflineAreaRecord>> list() async {
    final regions = await maplibre.getListOfRegions();
    final matching = regions.where(
      (region) =>
          region.metadata['owner'] == owner &&
          region.definition.mapStyleUrl == OfflineAreaPolicy.styleUrl,
    );

    final results = <OfflineAreaRecord>[];
    for (final region in matching) {
      maplibre.OfflineRegionStatus? status;
      try {
        status = await maplibre.getOfflineRegionStatus(region.id);
      } catch (_) {
        // A removed/incomplete region is never marked as complete.
      }
      results.add(OfflineAreaRecord(region, status));
    }
    return results;
  }

  /// Requests always use the current style and a restricted 1.5 km zone.
  /// For the full Swiss-country experience a licensed offline atlas is needed.
  Future<maplibre.OfflineRegion> download(
    OfflineAreaDraft area, {
    required void Function(maplibre.DownloadRegionStatus) onEvent,
  }) async {
    if (area.estimatedTiles > OfflineAreaPolicy.maxTiles) {
      throw StateError('Tile count exceeds provider policy');
    }

    // Provider requires a recognisable app User-Agent and no more than four
    // parallel tile requests. Do not use bulk-download APIs on this style.
    await maplibre.setHttpHeaders({
      'User-Agent': 'ReadySafe-SurvivalAtlas/4.0 (limited offline areas)',
    });
    await maplibre.setOfflineMaxConcurrentRequests(
      maxRequests: OfflineAreaPolicy.maxConcurrentRequests,
      maxRequestsPerHost: OfflineAreaPolicy.maxConcurrentRequests,
    );
    await maplibre.setOfflineTileCountLimit(OfflineAreaPolicy.maxTiles);

    final definition = maplibre.OfflineRegionDefinition(
      bounds: area.bounds,
      mapStyleUrl: OfflineAreaPolicy.styleUrl,
      minZoom: OfflineAreaPolicy.minZoom.toDouble(),
      maxZoom: OfflineAreaPolicy.maxZoom.toDouble(),
      includeIdeographs: false,
    );

    return maplibre.downloadOfflineRegion(
      definition,
      metadata: {
        'owner': owner,
        'name': area.label,
        'provider': 'OpenFreeMap',
        'attribution': OfflineAreaPolicy.attribution,
        'tileEstimate': area.estimatedTiles,
      },
      onEvent: onEvent,
    );
  }

  Future<void> delete(int id) => maplibre.deleteOfflineRegion(id);

  Future<maplibre.OfflineRegionStatus> status(int id) =>
      maplibre.getOfflineRegionStatus(id);
}
