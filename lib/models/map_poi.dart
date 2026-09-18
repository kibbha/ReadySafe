enum MapPoiKind {
  hospital,
  pharmacy,
  police,
  aed,
  drinkingWater,
}

enum MapPoiTrust {
  community,
  official,
}

class MapPoi {
  const MapPoi({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.kind,
    required this.trust,
    required this.sourceName,
    required this.sourceUrl,
    required this.distanceMeters,
    this.openingHours = '',
    this.address = '',
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final MapPoiKind kind;
  final MapPoiTrust trust;
  final String sourceName;
  final String sourceUrl;
  final double distanceMeters;
  final String openingHours;
  final String address;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'kind': kind.name,
        'trust': trust.name,
        'sourceName': sourceName,
        'sourceUrl': sourceUrl,
        'distanceMeters': distanceMeters,
        'openingHours': openingHours,
        'address': address,
      };

  factory MapPoi.fromJson(Map<String, dynamic> json) => MapPoi(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        kind: MapPoiKind.values.firstWhere(
          (value) => value.name == json['kind'],
          orElse: () => MapPoiKind.hospital,
        ),
        trust: MapPoiTrust.values.firstWhere(
          (value) => value.name == json['trust'],
          orElse: () => MapPoiTrust.community,
        ),
        sourceName: '${json['sourceName'] ?? ''}',
        sourceUrl: '${json['sourceUrl'] ?? ''}',
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
        openingHours: '${json['openingHours'] ?? ''}',
        address: '${json['address'] ?? ''}',
      );
}

class MapPoiLoadResult {
  const MapPoiLoadResult({
    required this.items,
    required this.fetchedAt,
    required this.fromCache,
    required this.stale,
    this.warning,
  });

  final List<MapPoi> items;
  final DateTime fetchedAt;
  final bool fromCache;
  final bool stale;
  final String? warning;
}
