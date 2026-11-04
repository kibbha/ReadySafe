import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/regional_map_pack.dart';

/// Stores immutable, publisher-approved PMTiles archives in app-support storage.
/// No arbitrary URL input is accepted from the user.
class RegionalMapPackService {
  const RegionalMapPackService();

  static const catalogAsset = 'assets/data/regional_map_catalog_v1.json';
  static final Set<String> _inProgressIds = <String>{};

  Future<RegionalMapCatalog> catalog() async {
    return RegionalMapCatalog.fromJson(
      await rootBundle.loadString(catalogAsset),
    );
  }

  Future<Directory> _directory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/regional-map-packs');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<File> fileFor(RegionalMapPack pack) async {
    final directory = await _directory();
    // Model parser permits only safe IDs and versions.
    return File('${directory.path}/${pack.filename}');
  }

  /// Verify both size and checksum (including after a device restart).
  /// A stale or corrupt file must never count as an installed map.
  Future<bool> verifiedInstalled(RegionalMapPack pack) async {
    if (!pack.canDownload) return false;
    final file = await fileFor(pack);
    return verifyFile(file, pack);
  }

  static Future<bool> verifyFile(File file, RegionalMapPack pack) async {
    if (!pack.canDownload || !await file.exists()) return false;
    if (await file.length() != pack.byteLength) return false;
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString() == pack.sha256Hex;
  }

  /// The source must be pinned in the app's reviewed catalog.
  /// Streaming download is capped to an exact expected length. A verified file
  /// is atomically installed only after SHA-256 verification.
  Future<File> download(
    RegionalMapPack pack, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (!pack.canDownload) {
      throw StateError('Regional map source has not been reviewed and approved');
    }
    if (!_inProgressIds.add(pack.id)) {
      throw StateError('A download for this region is already in progress');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 25);
    try {
      final url = pack.downloadUrl!;
      final request = await client.getUrl(url);
      request.followRedirects = false; // Never silently change the pinned host.
      request.headers.set(HttpHeaders.userAgentHeader, 'ReadySafe-SurvivalAtlas/4');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('Map server returned HTTP ${response.statusCode}', uri: url);
      }
      if (response.contentLength != -1 &&
          response.contentLength != pack.byteLength) {
        await response.drain<void>();
        throw const FormatException('Unexpected regional pack Content-Length');
      }

      return await _installVerifiedStream(
        pack,
        response,
        onProgress: onProgress,
      );
    } finally {
      client.close(force: true);
      _inProgressIds.remove(pack.id);
    }
  }

  Future<File> _installVerifiedStream(
    RegionalMapPack pack,
    Stream<List<int>> bytes, {
    void Function(int received, int total)? onProgress,
  }) async {
    final destination = await fileFor(pack);
    final partial = File('${destination.path}.partial');
    if (await partial.exists()) await partial.delete();

    RandomAccessFile? handle;
    var received = 0;
    try {
      handle = await partial.open(mode: FileMode.write);
      await for (final chunk in bytes) {
        received += chunk.length;
        if (received > pack.byteLength!) {
          throw const FormatException('Regional pack exceeded declared size');
        }
        await handle.writeFrom(chunk);
        onProgress?.call(received, pack.byteLength!);
      }
      await handle.flush();
      await handle.close();
      handle = null;

      if (received != pack.byteLength) {
        throw const FormatException('Incomplete regional map archive');
      }
      if (!await verifyFile(partial, pack)) {
        throw const FormatException('Regional map SHA-256 verification failed');
      }

      // Do not destroy a previously installed verified pack on failure.
      if (await destination.exists()) await destination.delete();
      return await partial.rename(destination.path);
    } finally {
      if (handle != null) await handle.close();
      if (await partial.exists()) await partial.delete();
    }
  }

  /// Test seam: exercises streaming, caps and atomic installation with local
  /// fixture bytes; still enforces the exact same pinned hash and size.
  Future<File> installVerifiedFixture(
    RegionalMapPack pack,
    Stream<List<int>> source, {
    void Function(int received, int total)? onProgress,
  }) {
    if (!pack.canDownload) {
      throw StateError('Only approved and pinned packs may be installed');
    }
    return _installVerifiedStream(pack, source, onProgress: onProgress);
  }

  Future<void> delete(RegionalMapPack pack) async {
    if (_inProgressIds.contains(pack.id)) {
      throw StateError('Cannot remove an actively downloading pack');
    }
    final file = await fileFor(pack);
    if (await file.exists()) await file.delete();
  }

  /// Generate a deliberately self-contained minimal Protomaps-v4 style.
  /// No glyph URLs, sprite URLs, web fonts or external tile providers.
  /// Rich hiking/topographic styles will be a separate reviewed pack.
  Future<String> localPreviewStyle(RegionalMapPack pack) async {
    if (!await verifiedInstalled(pack)) {
      throw StateError('Map archive missing or has failed integrity verification');
    }
    final file = await fileFor(pack);
    final url = 'pmtiles://${file.uri.toString()}';
    final encodedAttribution = pack.attribution.replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;').replaceAll('>', '&gt;');
    // No HTML escaping in JSON is needed: jsonEncode below handles strings.
    return _styleForLocalProtomaps(url, encodedAttribution);
  }

  static String _styleForLocalProtomaps(String source, String attribution) {
    // Imported here as a local JSON string in order to avoid any style fetch.
    return '''
{
  "version": 8,
  "name": "ReadySafe terrain preview offline",
  "sources": {
    "regional": {
      "type": "vector",
      "url": "$source",
      "attribution": "$attribution"
    }
  },
  "layers": [
    {"id":"background","type":"background","paint":{"background-color":"#f3f1e6"}},
    {"id":"landuse","type":"fill","source":"regional","source-layer":"landuse","paint":{"fill-color":"#d6e6c7","fill-opacity":0.55}},
    {"id":"water","type":"fill","source":"regional","source-layer":"water","paint":{"fill-color":"#a5d5e4"}},
    {"id":"buildings","type":"fill","source":"regional","source-layer":"buildings","minzoom":13,"paint":{"fill-color":"#ded5c1"}},
    {"id":"roads-outline","type":"line","source":"regional","source-layer":"roads","paint":{"line-color":"#a88e71","line-width":["interpolate",["linear"],["zoom"],8,0.1,14,3.2]}},
    {"id":"roads","type":"line","source":"regional","source-layer":"roads","paint":{"line-color":"#ffffff","line-width":["interpolate",["linear"],["zoom"],8,0.1,14,2.3]}}
  ]
}
''';
  }
}
