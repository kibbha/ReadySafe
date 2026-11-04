import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import '../models/gpx_route.dart';

/// Persistent GPX library, entirely local. No network and no background GPS.
class GpxLibraryService {
  const GpxLibraryService({this.rootDirectory});

  final Directory? rootDirectory;
  static const maxSavedRoutes = 30;
  static const maxNormalizedBytes = 4 * 1024 * 1024;

  Future<Directory> _directory() async {
    final parent = rootDirectory ?? await getApplicationSupportDirectory();
    final dir = Directory('${parent.path}/gpx-v4');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _file(String id) async {
    if (!RegExp(r'^gpx-[0-9]{10,18}$').hasMatch(id)) {
      throw const FormatException('Invalid GPX library identifier');
    }
    return File('${(await _directory()).path}/$id.json');
  }

  Future<List<GpxRoute>> list() async {
    final dir = await _directory();
    final items = <GpxRoute>[];
    final paths = await dir.list(followLinks: false).where(
      (entity) =>
          entity is File &&
          RegExp(r'gpx-[0-9]{10,18}\.json$').hasMatch(
            entity.uri.pathSegments.last,
          ),
    ).cast<File>().toList();
    // Most recently imported first, never parse unbounded directory contents.
    paths.sort((a, b) => b.path.compareTo(a.path));

    for (final file in paths.take(maxSavedRoutes)) {
      try {
        if (await file.length() > maxNormalizedBytes) continue;
        final raw = jsonDecode(await file.readAsString());
        if (raw is! Map<String, dynamic>) continue;
        final route = GpxRoute.fromJson(raw);
        if (file.uri.pathSegments.last != '${route.id}.json') continue;
        items.add(route);
      } catch (_) {
        // Corrupt GPX data must never crash emergency map access.
      }
    }
    return items;
  }

  Future<GpxRoute> importBytes(List<int> bytes, String suggestedName) async {
    if ((await list()).length >= maxSavedRoutes) {
      throw StateError('Maximum number of saved GPX traces reached');
    }
    final id = 'gpx-${DateTime.now().microsecondsSinceEpoch}';
    final route = GpxCodec.decode(
      bytes,
      id: id,
      fallbackName: suggestedName.replaceAll(
        RegExp(r'\.gpx$', caseSensitive: false), '',
      ),
    );
    final output = await _file(route.id);
    if (await output.exists()) {
      throw StateError('Duplicate GPX import identifier');
    }
    await _writeAtomic(output, route);
    return route;
  }

  Future<void> setVisibility(GpxRoute route, bool value) async {
    final file = await _file(route.id);
    if (!await file.exists()) throw StateError('Trace not found');
    await _writeAtomic(file, route.withVisibility(value));
  }

  Future<void> delete(GpxRoute route) async {
    final file = await _file(route.id);
    if (await file.exists()) await file.delete();
  }

  Future<void> _writeAtomic(File output, GpxRoute route) async {
    final bytes = utf8.encode(jsonEncode(route.toJson()));
    if (bytes.length > maxNormalizedBytes) {
      throw const FormatException('Normalized GPX exceeds local storage limit');
    }
    final partial = File('${output.path}.partial');
    try {
      await partial.writeAsBytes(bytes, flush: true);
      await partial.rename(output.path);
    } finally {
      if (await partial.exists()) await partial.delete();
    }
  }
}
