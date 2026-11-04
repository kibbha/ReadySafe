import 'dart:convert';

/// A catalog entry does NOT imply that its file has been approved or hosted.
/// Independent PMTiles archives require exact size, HTTPS URL and SHA-256.
class RegionalMapPack {
  const RegionalMapPack({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.country,
    required this.centreLat,
    required this.centreLon,
    required this.zoom,
    required this.tileSchema,
    required this.attribution,
    required this.license,
    required this.sourceLabel,
    required this.version,
    this.downloadUrl,
    this.byteLength,
    this.sha256Hex,
    this.approved = false,
    this.parentMapId,
  });

  final String id;
  final String nameFr;
  final String nameEn;
  final String country;
  final double centreLat;
  final double centreLon;
  final double zoom;
  final String tileSchema;
  final String attribution;
  final String license;
  final String sourceLabel;
  final String version;
  final Uri? downloadUrl;
  final int? byteLength;
  final String? sha256Hex;
  final bool approved;

  /// Only a `readysafe-contours-v1` archive has a parent map ID.
  final String? parentMapId;

  String name(bool english) => english ? nameEn : nameFr;

  bool get canDownload =>
      approved &&
      downloadUrl != null &&
      byteLength != null &&
      byteLength! >= 127 &&
      sha256Hex != null &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256Hex!) &&
      (tileSchema == 'protomaps-v4' ||
          (tileSchema == 'readysafe-contours-v1' &&
              parentMapId != null));

  String get filename => '$id-$version.pmtiles';

  factory RegionalMapPack.fromJson(Map<String, dynamic> json) {
    String string(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing regional map field: $key');
      }
      return value.trim();
    }

    double coord(String key, double minimum, double maximum) {
      final raw = json[key];
      if (raw is! num || !raw.isFinite ||
          raw.toDouble() < minimum || raw.toDouble() > maximum) {
        throw FormatException('Invalid regional map coordinate: $key');
      }
      return raw.toDouble();
    }

    final id = string('id');
    final version = string('version');
    const safeId = r'^[a-z0-9][a-z0-9_-]{1,59}$';
    if (!RegExp(safeId).hasMatch(id) ||
        !RegExp(r'^[a-zA-Z0-9._-]{1,32}$').hasMatch(version)) {
      throw const FormatException('Unsafe regional map filename');
    }

    final schema = string('tile_schema');
    if (schema != 'protomaps-v4' &&
        schema != 'readysafe-contours-v1') {
      throw const FormatException('Unsupported regional map tile schema');
    }

    final rawParent = json['parent_map_id'];
    if (schema == 'readysafe-contours-v1') {
      if (rawParent is! String ||
          !RegExp(safeId).hasMatch(rawParent)) {
        throw const FormatException('Contour pack requires a base map ID');
      }
    } else if (rawParent != null) {
      throw const FormatException('Base map cannot declare a contour parent');
    }

    final rawUrl = json['download_url'];
    Uri? url;
    if (rawUrl != null) {
      if (rawUrl is! String) {
        throw const FormatException('Invalid regional map URL');
      }
      url = Uri.tryParse(rawUrl);
      if (url == null ||
          url.scheme != 'https' ||
          !url.hasAuthority ||
          url.userInfo.isNotEmpty ||
          url.fragment.isNotEmpty ||
          !url.path.endsWith('.pmtiles')) {
        throw const FormatException('Map archive must use a direct HTTPS PMTiles URL');
      }
    }

    final bytes = json['byte_length'];
    if (bytes != null &&
        (bytes is! int || bytes < 127 ||
            bytes > 2 * 1024 * 1024 * 1024)) {
      throw const FormatException('Invalid or excessive PMTiles archive size');
    }
    final hash = json['sha256'];
    if (hash != null &&
        (hash is! String ||
            !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash))) {
      throw const FormatException('Invalid PMTiles SHA-256 fingerprint');
    }

    final approved = json['approved'] == true;
    if (approved && (url == null || bytes == null || hash == null)) {
      throw const FormatException('Approved pack needs URL, size and SHA-256');
    }

    return RegionalMapPack(
      id: id,
      nameFr: string('name_fr'),
      nameEn: string('name_en'),
      country: string('country'),
      centreLat: coord('centre_lat', -85, 85),
      centreLon: coord('centre_lon', -180, 180),
      zoom: coord('zoom', 0, 22),
      tileSchema: schema,
      attribution: string('attribution'),
      license: string('license'),
      sourceLabel: string('source_label'),
      version: version,
      downloadUrl: url,
      byteLength: bytes,
      sha256Hex: hash,
      approved: approved,
      parentMapId: rawParent is String ? rawParent : null,
    );
  }
}

class RegionalMapCatalog {
  const RegionalMapCatalog(
    this.packs, {
    this.contourPacks = const [],
  });

  final List<RegionalMapPack> packs;
  final List<RegionalMapPack> contourPacks;

  RegionalMapPack? contoursFor(String basemapId) {
    for (final pack in contourPacks) {
      if (pack.parentMapId == basemapId) return pack;
    }
    return null;
  }

  factory RegionalMapCatalog.fromJson(String data) {
    final decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic> ||
        decoded['schema_version'] != 1 ||
        decoded['packs'] is! List) {
      throw const FormatException('Invalid regional map catalog');
    }

    final ids = <String>{};
    final packs = <RegionalMapPack>[];
    for (final raw in decoded['packs'] as List) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid regional map entry');
      }
      final pack = RegionalMapPack.fromJson(raw);
      if (pack.tileSchema != 'protomaps-v4' || !ids.add(pack.id)) {
        throw const FormatException('Invalid or duplicate base map');
      }
      packs.add(pack);
    }

    final rawContours = decoded['contour_packs'];
    if (rawContours != null && rawContours is! List) {
      throw const FormatException('Invalid contour catalog');
    }

    final contours = <RegionalMapPack>[];
    final parents = <String>{};
    for (final raw in (rawContours as List? ?? const [])) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid contour record');
      }
      final pack = RegionalMapPack.fromJson(raw);
      if (pack.tileSchema != 'readysafe-contours-v1' ||
          !ids.add(pack.id) ||
          !packs.any((base) => base.id == pack.parentMapId) ||
          !parents.add(pack.parentMapId!)) {
        throw const FormatException('Contour pack has invalid or duplicate parent');
      }
      contours.add(pack);
    }

    return RegionalMapCatalog(
      List.unmodifiable(packs),
      contourPacks: List.unmodifiable(contours),
    );
  }
}
