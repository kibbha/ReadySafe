import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/country_repository.dart';
import 'package:readysafe/models/map_pack.dart';
import 'package:readysafe/services/map_pack_service.dart';

void main() {
  test(
    'unconfigured catalog lists every country without fake downloads',
    () async {
      final provider = UnconfiguredOfflineMapProvider();
      final catalog = await provider.catalog(null);
      expect(catalog.length, CountryRepository.supported.length);
      expect(
        catalog.every((pack) => pack.state == MapPackState.unavailable),
        isTrue,
      );
      expect(catalog.every((pack) => !pack.isConfigured), isTrue);
      expect(await provider.localStyleUri(catalog.first.id), isNull);
      expect(
        () => provider.download(catalog.first.id, (_) {}),
        throwsStateError,
      );
    },
  );
}
