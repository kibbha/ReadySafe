import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/map_pack.dart';
import 'package:readysafe/services/map_pack_service.dart';

void main() {
  test('unconfigured provider never pretends a pack is downloaded', () async {
    final provider = UnconfiguredOfflineMapProvider();
    final catalog = await provider.catalog('FR');
    expect(catalog.single.state, MapPackState.unavailable);
    expect(await provider.localStyleUri(catalog.single.id), isNull);
    expect(
      () => provider.download(catalog.single.id, (_) {}),
      throwsStateError,
    );
  });
}
