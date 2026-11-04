import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/local_pmtiles_service.dart';

/// PMTiles header/metadata fixture. Tile bytes are deliberately not rendered:
/// this tests format preflight and integrity, NOT native MapLibre rendering.
Uint8List fixture({
  bool gzipMetadata = true,
  bool validLayers = true,
  int centreZoom = 12,
}) {
  final layers = validLayers
      ? ['roads', 'water', 'landuse', 'pois', 'buildings']
      : ['missing-required-layers'];
  final metadata = utf8.encode(jsonEncode({
    'vector_layers': [
      for (final id in layers) {'id': id, 'fields': <String, String>{}},
    ],
  }));
  final packed = gzipMetadata ? gzip.encode(metadata) : metadata;
  final bytes = Uint8List(127 + 1 + packed.length + 8);
  bytes.setRange(0, 7, utf8.encode('PMTiles'));
  bytes[7] = 3;
  bytes[97] = gzipMetadata ? 2 : 1;
  bytes[98] = 2;
  bytes[99] = 1;
  bytes[100] = 0;
  bytes[101] = 15;
  bytes[118] = centreZoom;
  final header = ByteData.sublistView(bytes);
  header.setUint64(8, 127, Endian.little);
  header.setUint64(16, 1, Endian.little);
  header.setUint64(24, 128, Endian.little);
  header.setUint64(32, packed.length, Endian.little);
  header.setUint64(56, 128 + packed.length, Endian.little);
  header.setUint64(64, 8, Endian.little);
  header.setInt32(102, 61000000, Endian.little);
  header.setInt32(106, 461000000, Endian.little);
  header.setInt32(110, 63000000, Endian.little);
  header.setInt32(114, 463000000, Endian.little);
  header.setInt32(119, 62000000, Endian.little);
  header.setInt32(123, 462000000, Endian.little);
  bytes[127] = 1;
  bytes.setRange(128, 128 + packed.length, packed);
  return bytes;
}

void main() {
  test('imports, verifies, renders a local-only style and deletes', () async {
    final temp = await Directory.systemTemp.createTemp('rs-local-pm-');
    final service = LocalPmtilesService(rootDirectory: temp);
    try {
      final bytes = fixture();
      final pack = await service.importStream(
        Stream<List<int>>.value(bytes),
        expectedBytes: bytes.length,
        fileName: 'Leman.pmtiles',
      );
      expect(pack.name, 'Leman');
      expect(pack.latitude, closeTo(46.2, 0.00001));
      expect(pack.longitude, closeTo(6.2, 0.00001));
      expect(await service.verified(pack), isTrue);
      expect((await service.list()).single.id, pack.id);

      final style = jsonDecode(await service.style(pack)) as Map<String, dynamic>;
      final sources = style['sources'] as Map<String, dynamic>;
      expect((sources['regional'] as Map)['url'].toString(),
          startsWith('pmtiles://file:///'));
      expect(style.toString().contains('https://'), isFalse);
      expect(style.containsKey('glyphs'), isFalse);

      await expectLater(
        service.importStream(Stream<List<int>>.value(bytes),
            expectedBytes: bytes.length, fileName: 'Duplicate.pmtiles'),
        throwsStateError,
      );
      await service.delete(pack);
      expect(await service.list(), isEmpty);
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('rejects PNG tiles, incompatible layers and partial file streams',
      () async {
    final temp = await Directory.systemTemp.createTemp('rs-invalid-pm-');
    final service = LocalPmtilesService(rootDirectory: temp);
    try {
      final wrongType = fixture()..[99] = 2;
      await expectLater(
        service.importStream(Stream<List<int>>.value(wrongType),
            expectedBytes: wrongType.length, fileName: 'wrong.pmtiles'),
        throwsFormatException,
      );
      final wrongLayers = fixture(validLayers: false);
      await expectLater(
        service.importStream(Stream<List<int>>.value(wrongLayers),
            expectedBytes: wrongLayers.length, fileName: 'other.pmtiles'),
        throwsFormatException,
      );
      final valid = fixture(gzipMetadata: false);
      await expectLater(
        service.importStream(Stream<List<int>>.value(valid.sublist(0, 130)),
            expectedBytes: valid.length, fileName: 'partial.pmtiles'),
        throwsFormatException,
      );
      expect(await service.list(), isEmpty);
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('sha256 catches tampering before reopening a stored offline map',
      () async {
    final temp = await Directory.systemTemp.createTemp('rs-map-sha-');
    final service = LocalPmtilesService(rootDirectory: temp);
    try {
      final bytes = fixture();
      final pack = await service.importStream(
        Stream<List<int>>.value(bytes),
        expectedBytes: bytes.length,
        fileName: 'Safe.pmtiles',
      );
      final file = await service.fileFor(pack);
      final changed = await file.readAsBytes();
      changed[changed.length - 1] ^= 0xff;
      await file.writeAsBytes(changed, flush: true);
      expect(await service.verified(pack), isFalse);
      expect(await service.list(), isEmpty);
      await expectLater(service.style(pack), throwsStateError);
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('regional extract with zoom-zero header opens near actual region',
      () async {
    final temp = await Directory.systemTemp.createTemp('rs-header-z0-');
    try {
      final file = File('${temp.path}/geneva.pmtiles');
      await file.writeAsBytes(fixture(centreZoom: 0));
      final info = await ProtomapsV4Inspector.inspect(file);
      expect(info.zoom, greaterThan(8.5));
      expect(info.zoom, lessThan(12));
      expect(info.latitude, closeTo(46.2, 0.00001));
      expect(info.longitude, closeTo(6.2, 0.00001));
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('checks offsets and caps input before allocating huge memory', () async {
    final temp = await Directory.systemTemp.createTemp('rs-header-pm-');
    try {
      final file = File('${temp.path}/fixture.pmtiles');
      await file.writeAsBytes(fixture(gzipMetadata: false));
      final extent = await ProtomapsV4Inspector.inspect(file);
      expect(extent.latitude, closeTo(46.2, 0.00001));
      expect(extent.longitude, closeTo(6.2, 0.00001));
      expect(extent.zoom, 12);

      final bytes = await file.readAsBytes();
      ByteData.sublistView(bytes).setUint64(
        24, bytes.length + 1, Endian.little,
      );
      await file.writeAsBytes(bytes);
      await expectLater(ProtomapsV4Inspector.inspect(file), throwsFormatException);
      await expectLater(
        const LocalPmtilesService().importStream(
          const Stream<List<int>>.empty(),
          expectedBytes: LocalPmtilesService.maxImportBytes + 1,
          fileName: 'huge.pmtiles',
        ),
        throwsFormatException,
      );
    } finally {
      await temp.delete(recursive: true);
    }
  });
}
