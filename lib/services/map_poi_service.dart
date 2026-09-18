import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/map_poi.dart';

class MapPoiService {
  MapPoiService({
    this.freshFor = const Duration(hours: 12),
  });

  static const _endpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];
  static const _cachePrefix = 'readysafe.map_poi.v2';
  static const _sourceName = 'OpenStreetMap';
  static const _sourceCopyright = 'https://www.openstreetmap.org/copyright';

  final Duration freshFor;

  Future<MapPoiLoadResult> loadAround({
    required double latitude,
    required double longitude,
    int radiusMeters = 18000,
    bool force = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(latitude, longitude);
    final cached = _readCache(prefs.getString(key));

    if (!force &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) <= freshFor) {
      return cached;
    }

    try {
      final raw = await _requestOverpass(
        buildOverpassQuery(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
      );
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected Overpass response');
      }

      final items = parseOverpass(
        decoded,
        originLatitude: latitude,
        originLongitude: longitude,
      );
      final result = MapPoiLoadResult(
        items: items,
        fetchedAt: DateTime.now(),
        fromCache: false,
        stale: false,
      );
      await prefs.setString(key, _encodeCache(result));
      return result;
    } catch (error) {
      if (cached != null) {
        return MapPoiLoadResult(
          items: cached.items,
          fetchedAt: cached.fetchedAt,
          fromCache: true,
          stale: true,
          warning: error.toString(),
        );
      }
      rethrow;
    }
  }

  static String buildOverpassQuery({
    required double latitude,
    required double longitude,
    int radiusMeters = 18000,
  }) {
    final around = 'around:$radiusMeters,$latitude,$longitude';
    return '''
[out:json][timeout:18];
(
  nwr($around)["amenity"="hospital"];
  nwr($around)["amenity"="clinic"];
  nwr($around)["amenity"="pharmacy"];
  nwr($around)["amenity"="police"];
  nwr($around)["amenity"="drinking_water"];
  nwr($around)["healthcare"="hospital"];
  nwr($around)["healthcare"="clinic"];
  nwr($around)["healthcare"="pharmacy"];
  nwr($around)["emergency"="defibrillator"];
);
out center tags;
''';
  }

  static List<MapPoi> parseOverpass(
    Map<String, dynamic> decoded, {
    required double originLatitude,
    required double originLongitude,
  }) {
    final elements = decoded['elements'];
    if (elements is! List) return const [];

    final unique = <String, MapPoi>{};

    for (final raw in elements) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final tagsRaw = item['tags'];
      if (tagsRaw is! Map) continue;
      final tags = Map<String, dynamic>.from(tagsRaw);

      final kind = _kindFromTags(tags);
      if (kind == null) continue;

      final lat = (item['lat'] as num?)?.toDouble() ??
          ((item['center'] is Map)
              ? (Map<String, dynamic>.from(item['center'] as Map)['lat'] as num?)
                  ?.toDouble()
              : null);
      final lon = (item['lon'] as num?)?.toDouble() ??
          ((item['center'] is Map)
              ? (Map<String, dynamic>.from(item['center'] as Map)['lon'] as num?)
                  ?.toDouble()
              : null);

      if (lat == null || lon == null) continue;

      final type = '${item['type'] ?? 'node'}';
      final id = '${item['id'] ?? ''}';
      if (id.isEmpty) continue;

      final name = _bestName(tags, kind);
      final distance = _distanceMeters(
        originLatitude,
        originLongitude,
        lat,
        lon,
      );

      unique['$type:$id'] = MapPoi(
        id: '$type:$id',
        name: name,
        latitude: lat,
        longitude: lon,
        kind: kind,
        trust: MapPoiTrust.community,
        sourceName: _sourceName,
        sourceUrl: 'https://www.openstreetmap.org/$type/$id',
        distanceMeters: distance,
        openingHours: '${tags['opening_hours'] ?? ''}',
      );
    }

    final result = unique.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return result.take(120).toList();
  }

  static MapPoiKind? _kindFromTags(Map<String, dynamic> tags) {
    if (tags['emergency'] == 'defibrillator') return MapPoiKind.aed;

    final amenity = '${tags['amenity'] ?? ''}';
    final healthcare = '${tags['healthcare'] ?? ''}';

    if (amenity == 'pharmacy' || healthcare == 'pharmacy') {
      return MapPoiKind.pharmacy;
    }
    if (amenity == 'police') return MapPoiKind.police;
    if (amenity == 'drinking_water') return MapPoiKind.drinkingWater;
    if (amenity == 'hospital' ||
        amenity == 'clinic' ||
        healthcare == 'hospital' ||
        healthcare == 'clinic') {
      return MapPoiKind.hospital;
    }
    return null;
  }

  static String _bestName(
    Map<String, dynamic> tags,
    MapPoiKind kind,
  ) {
    for (final key in const ['name', 'brand', 'operator']) {
      final value = '${tags[key] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }

    return switch (kind) {
      MapPoiKind.hospital => 'Hospital / clinic',
      MapPoiKind.pharmacy => 'Pharmacy',
      MapPoiKind.police => 'Police',
      MapPoiKind.aed => 'AED',
      MapPoiKind.drinkingWater => 'Drinking water',
    };
  }

  static double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    double radians(double value) => value * math.pi / 180;

    final dLat = radians(lat2 - lat1);
    final dLon = radians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radians(lat1)) *
            math.cos(radians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  String _cacheKey(double latitude, double longitude) {
    final latBucket = (latitude * 10).round();
    final lonBucket = (longitude * 10).round();
    return '$_cachePrefix.$latBucket.$lonBucket';
  }

  MapPoiLoadResult? _readCache(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final timestamp = DateTime.tryParse('${map['fetchedAt'] ?? ''}');
      final itemsRaw = map['items'];
      if (timestamp == null || itemsRaw is! List) return null;
      return MapPoiLoadResult(
        items: itemsRaw
            .whereType<Map>()
            .map((item) => MapPoi.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        fetchedAt: timestamp,
        fromCache: true,
        stale: false,
      );
    } catch (_) {
      return null;
    }
  }

  String _encodeCache(MapPoiLoadResult result) => jsonEncode({
        'fetchedAt': result.fetchedAt.toIso8601String(),
        'items': result.items.map((item) => item.toJson()).toList(),
      });

  Future<String> _requestOverpass(String query) async {
    Object? lastError;

    for (final endpoint in _endpoints) {
      try {
        return await _requestEndpoint(endpoint, query);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ??
        HttpException('No Overpass endpoint could be reached');
  }

  Future<String> _requestEndpoint(String endpoint, String query) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 7);
    final uri = Uri.parse(endpoint);

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'ReadySafe/3.1 (+$_sourceCopyright)',
      );
      request.write('data=${Uri.encodeQueryComponent(query)}');

      final response =
          await request.close().timeout(const Duration(seconds: 18));
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 18));

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Overpass returned HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      return body;
    } finally {
      client.close(force: true);
    }
  }
}
