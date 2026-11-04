import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'regional_terrain_style.dart';

/// A user-provided map. Integrity is checked, geographic accuracy is NOT.
class LocalPmtilesPack {
  const LocalPmtilesPack({
    required this.id,
    required this.name,
    required this.sha256Hex,
    required this.byteLength,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.importedAt,
  });

  final String id;
  final String name;
  final String sha256Hex;
  final int byteLength;
  final double latitude;
  final double longitude;
  final double zoom;
  final String importedAt;

  static const attribution = '© OpenStreetMap contributors · Protomaps';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sha256': sha256Hex,
    'byte_length': byteLength,
    'latitude': latitude,
    'longitude': longitude,
    'zoom': zoom,
    'imported_at': importedAt,
  };

  factory LocalPmtilesPack.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final hash = json['sha256'];
    final length = json['byte_length'];
    final lat = json['latitude'];
    final lon = json['longitude'];
    final zoom = json['zoom'];
    final title = json['name'];
    final date = json['imported_at'];
    if (id is! String || !RegExp(r'^local-[a-f0-9]{24}$').hasMatch(id) ||
        hash is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        id != 'local-${hash.substring(0, 24)}' ||
        length is! int || length < 131 ||
        length > LocalPmtilesService.maxImportBytes ||
        lat is! num || lon is! num || zoom is! num ||
        !lat.isFinite || !lon.isFinite || !zoom.isFinite ||
        lat < -85 || lat > 85 || lon < -180 || lon > 180 ||
        zoom < 0 || zoom > 22 ||
        title is! String || title.isEmpty || title.length > 80 ||
        date is! String || DateTime.tryParse(date) == null) {
      throw const FormatException('Invalid imported offline map manifest');
    }
    return LocalPmtilesPack(
      id: id,
      name: title,
      sha256Hex: hash,
      byteLength: length,
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      zoom: zoom.toDouble(),
      importedAt: date,
    );
  }
}

class _BoundedMetadataSink implements Sink<List<int>> {
  static const maxBytes = 1024 * 1024;
  final output = <int>[];

  @override
  void add(List<int> chunk) {
    if (output.length + chunk.length > maxBytes) {
      throw const FormatException('PMTiles metadata decompression limit');
    }
    output.addAll(chunk);
  }

  @override
  void close() {}
}

/// Checks the PMTiles-v3 header, range bounds and Protomaps-v4 layer names.
/// Does NOT decode or certify every tile in a third-party archive.
class ProtomapsV4Inspector {
  const ProtomapsV4Inspector._();

  static Future<({double latitude, double longitude, double zoom})> inspect(
    File file,
  ) async {
    final size = await file.length();
    if (size < 131 || size > LocalPmtilesService.maxImportBytes) {
      throw const FormatException('PMTiles archive size is outside limit');
    }
    final handle = await file.open(mode: FileMode.read);
    try {
      final bytes = await handle.read(127);
      if (bytes.length != 127 ||
          utf8.decode(bytes.sublist(0, 7)) != 'PMTiles' ||
          bytes[7] != 3 || bytes[99] != 1) {
        throw const FormatException('Only PMTiles v3 vector MVT accepted');
      }
      final header = ByteData.sublistView(Uint8List.fromList(bytes));
      int word(int offset) => header.getUint64(offset, Endian.little);
      bool section(int offset, int length) =>
          offset >= 127 && length > 0 && offset <= size &&
          length <= size - offset;
      final rootOffset = word(8);
      final rootLength = word(16);
      final metaOffset = word(24);
      final metaLength = word(32);
      final tileOffset = word(56);
      final tileLength = word(64);
      if (!section(rootOffset, rootLength) ||
          rootOffset + rootLength > 16384 ||
          !section(metaOffset, metaLength) ||
          metaLength > 512 * 1024 ||
          !section(tileOffset, tileLength) ||
          bytes[100] > bytes[101] || bytes[101] > 22 ||
          (bytes[97] != 1 && bytes[97] != 2)) {
        throw const FormatException('Invalid PMTiles index or metadata');
      }
      await handle.setPosition(metaOffset);
      final compressed = await handle.read(metaLength);
      if (compressed.length != metaLength) {
        throw const FormatException('Truncated PMTiles metadata');
      }
      final sink = _BoundedMetadataSink();
      if (bytes[97] == 2) {
        final decoder = gzip.decoder.startChunkedConversion(sink);
        decoder.add(compressed);
        decoder.close();
      } else {
        sink.add(compressed);
      }
      final data = jsonDecode(utf8.decode(sink.output));
      if (data is! Map<String, dynamic> || data['vector_layers'] is! List) {
        throw const FormatException('Vector layer manifest is missing');
      }
      final layers = <String>{};
      for (final entry in data['vector_layers'] as List) {
        if (entry is Map && entry['id'] is String) {
          layers.add(entry['id'] as String);
        }
      }
      if (!{'roads', 'water', 'landuse', 'pois'}.every(layers.contains)) {
        throw const FormatException('Not compatible with Protomaps v4');
      }

      double coord(int offset) =>
          header.getInt32(offset, Endian.little) / 10000000.0;
      final west = coord(102);
      final south = coord(106);
      final east = coord(110);
      final north = coord(114);
      if (west < -180 || east > 180 || west > east ||
          south < -85 || north > 85 || south > north) {
        throw const FormatException('Invalid geographic coverage');
      }
      final centreLon = coord(119);
      final centreLat = coord(123);
      final lat = centreLat >= south && centreLat <= north
          ? centreLat : (north + south) / 2;
      final lon = centreLon >= west && centreLon <= east
          ? centreLon : (west + east) / 2;
      final zoom = bytes[118].toDouble()
          .clamp(bytes[100].toDouble(), bytes[101].toDouble())
          .toDouble();
      return (latitude: lat, longitude: lon, zoom: zoom);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Unreadable PMTiles metadata');
    } finally {
      await handle.close();
    }
  }
}

class LocalPmtilesService {
  const LocalPmtilesService({this.rootDirectory});

  final Directory? rootDirectory;
  static const maxMaps = 4;
  static const maxImportBytes = 250 * 1024 * 1024;
  static bool _importing = false;

  Future<Directory> _directory() async {
    final root = rootDirectory ?? await getApplicationSupportDirectory();
    final dir = Directory('${root.path}/local-atlas-v4');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> fileFor(LocalPmtilesPack pack) async {
    if (!RegExp(r'^local-[a-f0-9]{24}$').hasMatch(pack.id)) {
      throw const FormatException('Unsafe imported map identifier');
    }
    return File('${(await _directory()).path}/${pack.id}.pmtiles');
  }

  Future<bool> verified(LocalPmtilesPack pack) async {
    try {
      final file = await fileFor(pack);
      if (!await file.exists() || await file.length() != pack.byteLength) {
        return false;
      }
      await ProtomapsV4Inspector.inspect(file);
      final digest = await sha256.bind(file.openRead()).first;
      return digest.toString() == pack.sha256Hex;
    } catch (_) {
      return false;
    }
  }

  Future<List<LocalPmtilesPack>> list() async {
    final dir = await _directory();
    final manifests = await dir.list(followLinks: false)
        .where((f) => f is File &&
            RegExp(r'^local-[a-f0-9]{24}\.json$')
                .hasMatch(f.uri.pathSegments.last))
        .cast<File>()
        .take(maxMaps + 1)
        .toList();
    final result = <LocalPmtilesPack>[];
    for (final manifest in manifests) {
      try {
        if (await manifest.length() > 4096) continue;
        final decoded = jsonDecode(await manifest.readAsString());
        if (decoded is! Map<String, dynamic>) continue;
        final pack = LocalPmtilesPack.fromJson(decoded);
        if (manifest.uri.pathSegments.last != '${pack.id}.json') continue;
        if (await verified(pack)) result.add(pack);
      } catch (_) {
        // Missing or corrupted archives are never shown as available.
      }
    }
    result.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return result;
  }

  Future<LocalPmtilesPack> importStream(
    Stream<List<int>> data, {
    required int expectedBytes,
    required String fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    if (_importing) throw StateError('Another map import is in progress');
    if (expectedBytes < 131 || expectedBytes > maxImportBytes) {
      throw const FormatException('Map must be below 250 MiB');
    }
    _importing = true;
    File? partial;
    try {
      final dir = await _directory();
      if ((await list()).length >= maxMaps) {
        throw StateError('Maximum number of imported maps reached');
      }
      partial = File('${dir.path}/incoming-${DateTime.now().microsecondsSinceEpoch}.partial');
      final writer = await partial.open(mode: FileMode.write);
      var received = 0;
      try {
        await for (final chunk in data) {
          received += chunk.length;
          if (received > expectedBytes || received > maxImportBytes) {
            throw const FormatException('PMTiles input exceeded declared size');
          }
          await writer.writeFrom(chunk);
          onProgress?.call(received, expectedBytes);
        }
        await writer.flush();
      } finally {
        await writer.close();
      }
      if (received != expectedBytes) {
        throw const FormatException('Incomplete PMTiles import');
      }
      final info = await ProtomapsV4Inspector.inspect(partial);
      final digest = (await sha256.bind(partial.openRead()).first).toString();
      final id = 'local-${digest.substring(0, 24)}';
      final dest = File('${dir.path}/$id.pmtiles');
      final sidecar = File('${dir.path}/$id.json');
      if (await dest.exists() || await sidecar.exists()) {
        throw StateError('This map is already imported');
      }
      final cleaned = fileName
          .replaceAll(RegExp(r'\.pmtiles$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
          .trim();
      final name = cleaned.isEmpty
          ? 'Carte importée'
          : cleaned.substring(0, cleaned.length > 80 ? 80 : cleaned.length);
      final pack = LocalPmtilesPack(
        id: id,
        name: name,
        sha256Hex: digest,
        byteLength: received,
        latitude: info.latitude,
        longitude: info.longitude,
        zoom: info.zoom,
        importedAt: DateTime.now().toUtc().toIso8601String(),
      );
      await partial.rename(dest.path);
      partial = null;
      try {
        await sidecar.writeAsString(jsonEncode(pack.toJson()), flush: true);
      } catch (_) {
        if (await dest.exists()) await dest.delete();
        rethrow;
      }
      return pack;
    } finally {
      if (partial != null && await partial.exists()) await partial.delete();
      _importing = false;
    }
  }

  Future<String> style(LocalPmtilesPack pack) async {
    if (!await verified(pack)) {
      throw StateError('Imported map failed integrity verification');
    }
    final file = await fileFor(pack);
    return RegionalTerrainStyle.build(
      basemapUri: 'pmtiles://${file.uri}',
      attribution: LocalPmtilesPack.attribution,
    );
  }

  Future<void> delete(LocalPmtilesPack pack) async {
    if (_importing) throw StateError('Cannot delete during map import');
    final file = await fileFor(pack);
    final manifest = File('${(await _directory()).path}/${pack.id}.json');
    if (await manifest.exists()) await manifest.delete();
    if (await file.exists()) await file.delete();
  }
}
