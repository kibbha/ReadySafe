import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/map_pack.dart';

abstract interface class MapDownloadSource {
  Stream<List<int>> open(Uri uri, {int startByte = 0});
}

abstract interface class MapPackStore {
  Future<int> partialLength(String packId);
  Future<IOSink> openPartial(String packId, {required bool append});
  Future<File> partialFile(String packId);
  Future<File> installedFile(String packId);
  Future<void> promote(String packId);
  Future<void> delete(String packId);
}

class DirectoryMapPackStore implements MapPackStore {
  DirectoryMapPackStore(this.root);
  final Directory root;
  Future<void> _ready() => root.create(recursive: true);
  @override
  Future<File> partialFile(String id) async {
    await _ready();
    return File('${root.path}/$id.part');
  }

  @override
  Future<File> installedFile(String id) async {
    await _ready();
    return File('${root.path}/$id.pmtiles');
  }

  @override
  Future<int> partialLength(String id) async {
    final file = await partialFile(id);
    return file.existsSync() ? file.length() : 0;
  }

  @override
  Future<IOSink> openPartial(String id, {required bool append}) async =>
      (await partialFile(
        id,
      )).openWrite(mode: append ? FileMode.append : FileMode.write);
  @override
  Future<void> promote(String id) async {
    final source = await partialFile(id);
    final target = await installedFile(id);
    if (await target.exists()) await target.delete();
    await source.rename(target.path);
  }

  @override
  Future<void> delete(String id) async {
    for (final file in [await partialFile(id), await installedFile(id)]) {
      if (await file.exists()) await file.delete();
    }
  }
}

class MapIntegrityVerifier {
  const MapIntegrityVerifier();
  Future<bool> verify(
    File file, {
    required String sha256Hex,
    required int expectedBytes,
  }) async {
    if (!await file.exists() || await file.length() != expectedBytes) {
      return false;
    }
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString().toLowerCase() == sha256Hex.toLowerCase();
  }
}

/// Download engine independent from catalog and rendering. Supports resuming
/// through byte ranges supplied by [MapDownloadSource]. A pack is promoted to
/// installed only after exact size and SHA-256 validation.
class VerifiedMapDownloader {
  VerifiedMapDownloader({
    required this.source,
    required this.store,
    this.verifier = const MapIntegrityVerifier(),
  });
  final MapDownloadSource source;
  final MapPackStore store;
  final MapIntegrityVerifier verifier;
  final Set<String> _paused = {};
  void pause(String id) => _paused.add(id);
  Future<MapPack> download(
    MapPack pack,
    void Function(double) onProgress,
  ) async {
    if (!pack.isConfigured) {
      throw StateError('Pack metadata incomplete');
    }
    _paused.remove(pack.id);
    final start = await store.partialLength(pack.id);
    final sink = await store.openPartial(pack.id, append: start > 0);
    var received = start;
    try {
      await for (final chunk in source.open(
        pack.downloadUri!,
        startByte: start,
      )) {
        if (_paused.contains(pack.id)) {
          break;
        }
        sink.add(chunk);
        received += chunk.length;
        onProgress(received / pack.estimatedBytes!);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    if (_paused.contains(pack.id)) {
      return pack.copyWith(
        state: MapPackState.paused,
        downloadedBytes: received,
      );
    }
    final partial = await store.partialFile(pack.id);
    final valid = await verifier.verify(
      partial,
      sha256Hex: pack.sha256!,
      expectedBytes: pack.estimatedBytes!,
    );
    if (!valid) {
      return pack.copyWith(
        state: MapPackState.failed,
        downloadedBytes: received,
      );
    }
    await store.promote(pack.id);
    final installed = await store.installedFile(pack.id);
    return pack.copyWith(
      state: MapPackState.installed,
      localPath: installed.path,
      downloadedBytes: received,
    );
  }
}
