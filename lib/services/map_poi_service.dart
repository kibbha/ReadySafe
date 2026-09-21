import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/map_poi.dart';

class MapPoiService {
  MapPoiService({
    this.freshFor = const Duration(hours: 12),
  });

  static const _overpassEndpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static const _cachePrefix = 'readysafe.map_poi.v3';
  static const _osmSourceName = 'OpenStreetMap';
  static const _osmCopyright = 'https://www.openstreetmap.org/copyright';

  static const _sitgDatasets = <_SitgDataset>[
    _SitgDataset(
      id: 'DAS_HOPITAUX_CLINIQUES',
      kind: MapPoiKind.hospital,
      sourceName: 'État de Genève · Santé / SITG',
      sourceUrl: 'https://sitg.ge.ch/donnees/das-hopitaux-cliniques',
      nameFields: ['NOM_ETABLISSEMENT', 'TYPE_ETABLISSEMENT'],
    ),
    _SitgDataset(
      id: 'POL_POSTE_POLICE',
      kind: MapPoiKind.police,
      sourceName: 'Police cantonale genevoise / SITG',
      sourceUrl: 'https://sitg.ge.ch/donnees/pol-poste-police',
      nameFields: ['DENOMINATION', 'TYPOLOGIE_POSTE'],
    ),
    _SitgDataset(
      id: 'DEAS_144_DEFIBRILLATEURS',
      kind: MapPoiKind.aed,
      sourceName: 'État de Genève · Santé / SITG',
      sourceUrl: 'https://sitg.ge.ch/donnees/deas-144-defibrillateurs',
      nameFields: ['TYPE_DE_LIEU', 'ADRESSE'],
    ),
    _SitgDataset(
      id: 'GEO_SANTE_VACCINATION_PHARM',
      kind: MapPoiKind.pharmacy,
      sourceName: 'État de Genève · Santé / SITG',
      sourceUrl: 'https://sitg.ge.ch/donnees/geo-sante-vaccination-pharm',
      nameFields: ['NOM_SITE', 'ADRESSE'],
    ),
  ];

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

    final warnings = <String>[];
    var official = <MapPoi>[];
    var community = <MapPoi>[];

    if (_isGenevaArea(latitude, longitude)) {
      final officialResult = await _loadGenevaOfficial(
        latitude: latitude,
        longitude: longitude,
      );
      official = officialResult.items;
      warnings.addAll(officialResult.warnings);
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
      community = parseOverpass(
        decoded,
        originLatitude: latitude,
        originLongitude: longitude,
      );
    } catch (error) {
      warnings.add('OpenStreetMap: $error');
    }

    final items = mergePreferOfficial(official, community);

    if (items.isEmpty) {
      if (cached != null) {
        return MapPoiLoadResult(
          items: cached.items,
          fetchedAt: cached.fetchedAt,
          fromCache: true,
          stale: true,
          warning: warnings.join(' · '),
        );
      }
      throw HttpException(
        warnings.isEmpty
            ? 'No map provider returned useful places'
            : warnings.join(' · '),
      );
    }

    final result = MapPoiLoadResult(
      items: items,
      fetchedAt: DateTime.now(),
      fromCache: false,
      stale: false,
      warning: warnings.isEmpty ? null : warnings.join(' · '),
    );
    await prefs.setString(key, _encodeCache(result));
    return result;
  }

  static bool _isGenevaArea(double latitude, double longitude) =>
      latitude >= 46.04 &&
      latitude <= 46.40 &&
      longitude >= 5.84 &&
      longitude <= 6.36;

  Future<({List<MapPoi> items, List<String> warnings})> _loadGenevaOfficial({
    required double latitude,
    required double longitude,
  }) async {
    final items = <MapPoi>[];
    final warnings = <String>[];

    for (final dataset in _sitgDatasets) {
      try {
        final raw = await _requestGet(
          buildSitgQueryUri(
            dataset.id,
            latitude: latitude,
            longitude: longitude,
          ),
        );
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Unexpected SITG response');
        }
        items.addAll(
          parseSitgFeatures(
            decoded,
            datasetId: dataset.id,
            originLatitude: latitude,
            originLongitude: longitude,
          ),
        );
      } catch (error) {
        warnings.add('${dataset.id}: $error');
      }
    }

    items.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return (items: items, warnings: warnings);
  }

  static Uri buildSitgQueryUri(
    String datasetId, {
    required double latitude,
    required double longitude,
  }) {
    final latSpan = 0.24;
    final lonSpan = 0.34;
    final envelope =
        '${longitude - lonSpan},${latitude - latSpan},'
        '${longitude + lonSpan},${latitude + latSpan}';

    return Uri.https(
      'vector.sitg.ge.ch',
      '/arcgis/rest/services/$datasetId/MapServer/0/query',
      {
        'where': '1=1',
        'outFields': '*',
        'returnGeometry': 'true',
        'geometry': envelope,
        'geometryType': 'esriGeometryEnvelope',
        'inSR': '4326',
        'outSR': '4326',
        'spatialRel': 'esriSpatialRelIntersects',
        'resultRecordCount': '2000',
        'f': 'json',
      },
    );
  }

  static List<MapPoi> parseSitgFeatures(
    Map<String, dynamic> decoded, {
    required String datasetId,
    required double originLatitude,
    required double originLongitude,
  }) {
    _SitgDataset? dataset;
    for (final item in _sitgDatasets) {
      if (item.id == datasetId) {
        dataset = item;
        break;
      }
    }
    if (dataset == null) return const [];

    final rawFeatures = decoded['features'];
    if (rawFeatures is! List) return const [];

    final items = <MapPoi>[];

    for (final raw in rawFeatures) {
      if (raw is! Map) continue;
      final feature = Map<String, dynamic>.from(raw);
      final attributesRaw = feature['attributes'];
      if (attributesRaw is! Map) continue;
      final attributes = Map<String, dynamic>.from(attributesRaw);

      final geometry = feature['geometry'] is Map
          ? Map<String, dynamic>.from(feature['geometry'] as Map)
          : const <String, dynamic>{};

      final latitude = (geometry['y'] as num?)?.toDouble() ??
          _parseDouble(attributes['COORD_WGS84_LATITUDE']);
      final longitude = (geometry['x'] as num?)?.toDouble() ??
          _parseDouble(attributes['COORD_WGS84_LONGITUDE']);

      if (latitude == null || longitude == null) continue;

      final objectId = '${attributes['OBJECTID'] ?? ''}'.trim();
      final name = _bestOfficialName(dataset, attributes);
      final address = '${attributes['ADRESSE'] ?? ''}'.trim();
      final h24 = '${attributes['H24'] ?? ''}'.toLowerCase();
      final hours = h24 == 'oui'
          ? '24/7'
          : '${attributes['HORAIRE'] ?? ''}'.trim();

      items.add(
        MapPoi(
          id: 'sitg:$datasetId:$objectId:$latitude:$longitude',
          name: name,
          latitude: latitude,
          longitude: longitude,
          kind: dataset.kind,
          trust: MapPoiTrust.official,
          sourceName: dataset.sourceName,
          sourceUrl: dataset.sourceUrl,
          distanceMeters: _distanceMeters(
            originLatitude,
            originLongitude,
            latitude,
            longitude,
          ),
          openingHours: hours,
          address: address,
        ),
      );
    }

    items.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return items;
  }

  static String _bestOfficialName(
    _SitgDataset dataset,
    Map<String, dynamic> attributes,
  ) {
    for (final field in dataset.nameFields) {
      final value = '${attributes[field] ?? ''}'.trim();
      if (value.isNotEmpty) {
        if (dataset.kind == MapPoiKind.aed && field == 'TYPE_DE_LIEU') {
          return 'DAE · $value';
        }
        return value;
      }
    }

    return switch (dataset.kind) {
      MapPoiKind.hospital => 'Hôpital / clinique',
      MapPoiKind.pharmacy => 'Pharmacie',
      MapPoiKind.police => 'Police',
      MapPoiKind.fireStation => 'Caserne de pompiers',
      MapPoiKind.aed => 'DAE',
      MapPoiKind.drinkingWater => 'Eau potable',
    };
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}'.replaceAll(',', '.'));
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
  nwr($around)["amenity"="fire_station"];
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

      unique['$type:$id'] = MapPoi(
        id: '$type:$id',
        name: _bestCommunityName(tags, kind),
        latitude: lat,
        longitude: lon,
        kind: kind,
        trust: MapPoiTrust.community,
        sourceName: _osmSourceName,
        sourceUrl: 'https://www.openstreetmap.org/$type/$id',
        distanceMeters: _distanceMeters(
          originLatitude,
          originLongitude,
          lat,
          lon,
        ),
        openingHours: '${tags['opening_hours'] ?? ''}',
        address: _osmAddress(tags),
      );
    }

    final result = unique.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return result.take(160).toList();
  }

  static String _osmAddress(Map<String, dynamic> tags) {
    final number = '${tags['addr:housenumber'] ?? ''}'.trim();
    final street = '${tags['addr:street'] ?? ''}'.trim();
    final city = '${tags['addr:city'] ?? ''}'.trim();
    final first = [street, number].where((value) => value.isNotEmpty).join(' ');
    return [first, city].where((value) => value.isNotEmpty).join(', ');
  }

  static List<MapPoi> mergePreferOfficial(
    List<MapPoi> official,
    List<MapPoi> community,
  ) {
    final merged = <MapPoi>[...official];

    for (final candidate in community) {
      final duplicate = official.any(
        (authorityPoi) =>
            authorityPoi.kind == candidate.kind &&
            _distanceMeters(
                  authorityPoi.latitude,
                  authorityPoi.longitude,
                  candidate.latitude,
                  candidate.longitude,
                ) <
                180,
      );
      if (!duplicate) merged.add(candidate);
    }

    merged.sort((a, b) {
      if (a.trust != b.trust) {
        return a.trust == MapPoiTrust.official ? -1 : 1;
      }
      return a.distanceMeters.compareTo(b.distanceMeters);
    });
    return merged;
  }

  static MapPoiKind? _kindFromTags(Map<String, dynamic> tags) {
    if (tags['emergency'] == 'defibrillator') return MapPoiKind.aed;

    final amenity = '${tags['amenity'] ?? ''}';
    final healthcare = '${tags['healthcare'] ?? ''}';

    if (amenity == 'pharmacy' || healthcare == 'pharmacy') {
      return MapPoiKind.pharmacy;
    }
    if (amenity == 'police') return MapPoiKind.police;
    if (amenity == 'fire_station') return MapPoiKind.fireStation;
    if (amenity == 'drinking_water') return MapPoiKind.drinkingWater;
    if (amenity == 'hospital' ||
        amenity == 'clinic' ||
        healthcare == 'hospital' ||
        healthcare == 'clinic') {
      return MapPoiKind.hospital;
    }
    return null;
  }

  static String _bestCommunityName(
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
      MapPoiKind.fireStation => 'Fire station',
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

    for (final endpoint in _overpassEndpoints) {
      try {
        return await _requestPost(endpoint, query);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ??
        HttpException('No Overpass endpoint could be reached');
  }

  Future<String> _requestPost(String endpoint, String query) async {
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
        'ReadySafe/3.4.4 (+$_osmCopyright)',
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
          'Provider returned HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      return body;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _requestGet(Uri uri) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 7);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'ReadySafe/3.4.4',
      );
      final response =
          await request.close().timeout(const Duration(seconds: 18));
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'SITG returned HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      return body;
    } finally {
      client.close(force: true);
    }
  }
}

class _SitgDataset {
  const _SitgDataset({
    required this.id,
    required this.kind,
    required this.sourceName,
    required this.sourceUrl,
    required this.nameFields,
  });

  final String id;
  final MapPoiKind kind;
  final String sourceName;
  final String sourceUrl;
  final List<String> nameFields;
}
