enum MapPackState { unavailable, available, downloading, installed, failed }

class MapPack {
  const MapPack({
    required this.id,
    required this.countryCode,
    required this.name,
    required this.estimatedBytes,
    required this.state,
    this.licenseName = 'OpenStreetMap contributors',
    this.licenseUrl = 'https://www.openstreetmap.org/copyright',
  });
  final String id;
  final String countryCode;
  final String name;
  final int? estimatedBytes;
  final MapPackState state;
  final String licenseName;
  final String licenseUrl;

  MapPack copyWith({MapPackState? state}) => MapPack(
    id: id,
    countryCode: countryCode,
    name: name,
    estimatedBytes: estimatedBytes,
    state: state ?? this.state,
    licenseName: licenseName,
    licenseUrl: licenseUrl,
  );
}
