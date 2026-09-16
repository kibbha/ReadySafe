import '../models/map_pack.dart';

abstract interface class OfflineMapProvider {
  Future<List<MapPack>> catalog(String countryCode);
  Future<void> download(
    String packId,
    void Function(double progress) onProgress,
  );
  Future<void> delete(String packId);
  Future<String?> localStyleUri(String packId);
}

/// Safe default until a licensed regional provider or externally supplied
/// PMTiles/MBTiles catalog is configured. It never contacts public OSM tiles.
class UnconfiguredOfflineMapProvider implements OfflineMapProvider {
  @override
  Future<List<MapPack>> catalog(String countryCode) async => [
    MapPack(
      id: '$countryCode-national',
      countryCode: countryCode,
      name: countryCode,
      estimatedBytes: null,
      state: MapPackState.unavailable,
    ),
  ];
  @override
  Future<void> download(
    String packId,
    void Function(double progress) onProgress,
  ) => throw StateError('No offline map provider configured');
  @override
  Future<void> delete(String packId) async {}
  @override
  Future<String?> localStyleUri(String packId) async => null;
}
