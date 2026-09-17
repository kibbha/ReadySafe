import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/map_pack.dart';
import 'package:readysafe/services/map_download_service.dart';

class _MemorySource implements MapDownloadSource {
  _MemorySource(this.bytes);
  final List<int> bytes;
  @override
  Stream<List<int>> open(Uri uri, {int startByte = 0}) =>
      Stream.value(bytes.sublist(startByte));
}

void main() {
  test(
    'download is offline-ready only after size and SHA-256 validation',
    () async {
      final bytes = List<int>.generate(1024, (i) => i % 251);
      final directory = await Directory.systemTemp.createTemp(
        'readysafe-map-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = DirectoryMapPackStore(directory);
      final downloader = VerifiedMapDownloader(
        source: _MemorySource(bytes),
        store: store,
      );
      final pack = MapPack(
        id: 'FR-test',
        countryCode: 'FR',
        nameKey: 'country_france',
        version: '1',
        estimatedBytes: bytes.length,
        state: MapPackState.available,
        downloadUri: Uri.parse('https://packs.example.test/fr.pmtiles'),
        sha256: sha256.convert(bytes).toString(),
      );
      final result = await downloader.download(pack, (_) {});
      expect(result.state, MapPackState.installed);
      expect(result.localPath, isNotNull);
      expect(await File(result.localPath!).readAsBytes(), bytes);
      expect(await store.partialFile(pack.id).then((f) => f.exists()), isFalse);
    },
  );
  test('invalid payload is never promoted to installed', () async {
    final directory = await Directory.systemTemp.createTemp(
      'readysafe-map-invalid',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = DirectoryMapPackStore(directory);
    final downloader = VerifiedMapDownloader(
      source: _MemorySource([1, 2, 3]),
      store: store,
    );
    final pack = MapPack(
      id: 'bad',
      countryCode: 'FR',
      nameKey: 'country_france',
      version: '1',
      estimatedBytes: 3,
      state: MapPackState.available,
      downloadUri: Uri.parse('https://packs.example.test/bad.pmtiles'),
      sha256: '00',
    );
    final result = await downloader.download(pack, (_) {});
    expect(result.state, MapPackState.failed);
    expect(await store.installedFile(pack.id).then((f) => f.exists()), isFalse);
  });
}
