import '../data/country_repository.dart';
import '../models/map_pack.dart';

abstract interface class OfflineMapProvider {
  Future<List<MapPack>> catalog(String? countryCode);
  Future<MapPack> download(
    String packId,
    void Function(double progress) onProgress,
  );
  Future<MapPack> verify(String packId);
  Future<void> pause(String packId);
  Future<MapPack> resume(
    String packId,
    void Function(double progress) onProgress,
  );
  Future<void> delete(String packId);
  Future<String?> localStyleUri(String packId);
}

/// Catalog used until a legally licensed PMTiles provider is configured.
/// Every European country is visible, but no pack is downloadable and no
/// request is ever made to public OpenStreetMap tile servers.
class UnconfiguredOfflineMapProvider implements OfflineMapProvider {
  @override
  Future<List<MapPack>> catalog(String? countryCode) async => CountryRepository
      .supported
      .where((country) => countryCode == null || country.isoCode == countryCode)
      .map(
        (country) => MapPack(
          id: '${country.isoCode}-national',
          countryCode: country.isoCode,
          nameKey: country.nameKey,
          version: 'unconfigured',
          state: MapPackState.unavailable,
        ),
      )
      .toList();

  Never _notConfigured() =>
      throw StateError('No licensed offline map provider configured');
  @override
  Future<MapPack> download(
    String packId,
    void Function(double progress) onProgress,
  ) async => _notConfigured();
  @override
  Future<MapPack> verify(String packId) async => _notConfigured();
  @override
  Future<void> pause(String packId) async => _notConfigured();
  @override
  Future<MapPack> resume(
    String packId,
    void Function(double progress) onProgress,
  ) async => _notConfigured();
  @override
  Future<void> delete(String packId) async {}
  @override
  Future<String?> localStyleUri(String packId) async => null;
}
