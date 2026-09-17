enum MapPackState {
  unavailable,
  available,
  downloading,
  paused,
  installed,
  updateAvailable,
  failed,
}

class MapPack {
  const MapPack({
    required this.id,
    required this.countryCode,
    required this.nameKey,
    required this.version,
    required this.state,
    this.estimatedBytes,
    this.downloadUri,
    this.sha256,
    this.localPath,
    this.downloadedBytes = 0,
    this.licenseName = 'OpenStreetMap contributors',
    this.licenseUrl = 'https://www.openstreetmap.org/copyright',
  });

  final String id;
  final String countryCode;
  final String nameKey;
  final String version;
  final int? estimatedBytes;
  final MapPackState state;
  final Uri? downloadUri;
  final String? sha256;
  final String? localPath;
  final int downloadedBytes;
  final String licenseName;
  final String licenseUrl;

  bool get isConfigured =>
      downloadUri != null && sha256 != null && estimatedBytes != null;
  bool get isInstalled => state == MapPackState.installed;
  double? get progress => estimatedBytes == null || estimatedBytes == 0
      ? null
      : (downloadedBytes / estimatedBytes!).clamp(0, 1);

  MapPack copyWith({
    MapPackState? state,
    String? localPath,
    int? downloadedBytes,
  }) => MapPack(
    id: id,
    countryCode: countryCode,
    nameKey: nameKey,
    version: version,
    estimatedBytes: estimatedBytes,
    state: state ?? this.state,
    downloadUri: downloadUri,
    sha256: sha256,
    localPath: localPath ?? this.localPath,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    licenseName: licenseName,
    licenseUrl: licenseUrl,
  );
}
