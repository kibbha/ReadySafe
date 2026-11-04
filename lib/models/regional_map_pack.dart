import 'dart:convert';

/// A catalog entry is NOT a claim that a region is downloadable.
/// Only a pinned source URL, byte count, SHA-256 and explicit approval unlock it.
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

  final String id, nameFr, nameEn, country, tileSchema;
  final String attribution, license, sourceLabel, version;
  final double centreLat, centreLon, zoom;
  final Uri? downloadUrl;
  final int? byteLength;
  final String? sha256Hex;
  final bool approved;
  /// Non-null only for a separately reviewed contour PMTiles archive.
  final String? parentMapId;

  String name(bool english) => english ? nameEn : nameFr;

  bool get canDownload =>
      approved &&
      downloadUrl != null &&
      byteLength != null &&
      byteLength! > 0 &&
      sha256Hex != null &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256Hex!) &&
      (tileSchema == 'protomaps-v4' ||
          tileSchema == 'readysafe-contours-v1');

  String get filename => '$id-$version.pmtiles';

  factory RegionalMapPack.fromJson(Map<String, dynamic> json) {
    String string(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing regional map field: $key');
      }
      return value.trim();
    }
    double coord(String key, double min, double max) {
      final value = json[key];
      if (value is! num || !value.isFinite ||
          value.toDouble() < min || value.toDouble() > max) {
        throw FormatException('Invalid $key');
      }
      return value.toDouble();
    }

    final id = string('id');
    final version = string('version');
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]{1,59}$').hasMatch(id) ||
        !RegExp(r'^[a-zA-Z0-9._-]{1,32}$').hasMatch(version)) {
      throw const FormatException('Unsafe pack identifier/version');
    }
    final schema = string('tile_schema');
    if (schema != 'protomaps-v4' &&
        schema != 'readysafe-contours-v1') {
      throw const FormatException('Unsupported map tile schema');
    }
    final rawParent = json['parent_map_id'];
    if (schema == 'readysafe-contours-v1') {
      if (rawParent is! String ||
          !RegExp(r'^[a-z0-9][a-z0-9_-]{1,59}

    final urlRaw = json['download_url'];
    Uri? url;
    if (urlRaw != null) {
      if (urlRaw is! String) throw const FormatException('Invalid pack URL');
      url = Uri.tryParse(urlRaw);
      if (url == null || url.scheme != 'https' || !url.hasAuthority ||
          url.userInfo.isNotEmpty || url.fragment.isNotEmpty ||
          !url.path.endsWith('.pmtiles')) {
        throw const FormatException('Map pack URL must be a direct HTTPS PMTiles file');
      }
    }
    final bytes = json['byte_length'];
    if (bytes != null && (bytes is! int || bytes <= 0 ||
        bytes > 2 * 1024 * 1024 * 1024)) {
      throw const FormatException('Invalid or excessive map pack size');
    }
    final hash = json['sha256'];
    if (hash != null && (hash is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash))) {
      throw const FormatException('Invalid SHA-256 fingerprint');
    }
    final approved = json['approved'] == true;
    if (approved && (url == null || bytes == null || hash == null)) {
      throw const FormatException('Approved map pack must pin source, bytes and SHA-256');
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
  const RegionalMapCatalog(this.packs, {this.contourPacks = const []});

  final List<RegionalMapPack> packs;
  final List<RegionalMapPack> contourPacks;

  RegionalMapPack? contoursFor(String basemapId) {
    for (final overlay in contourPacks) {
      if (overlay.parentMapId == basemapId) return overlay;
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
      if (!ids.add(pack.id)) throw FormatException('Duplicate regional map pack: ${pack.id}');
      packs.add(pack);
    }
    final contourPacks = <RegionalMapPack>[];
    final parentIds = <String>{};
    final rawContours = decoded['contour_packs'];
    if (rawContours != null && rawContours is! List) {
      throw const FormatException('Invalid contour archive catalog');
    }
    for (final raw in (rawContours as List? ?? const [])) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid contour pack');
      }
      final contour = RegionalMapPack.fromJson(raw);
      if (contour.tileSchema != 'readysafe-contours-v1' ||
          !ids.add(contour.id) ||
          !packs.any((base) => base.id == contour.parentMapId) ||
          !parentIds.add(contour.parentMapId!)) {
        throw const FormatException('Contour pack has invalid or duplicate parent');
      }
      contourPacks.add(contour);
    }

    return RegionalMapCatalog(
      List.unmodifiable(packs),
      contourPacks: List.unmodifiable(contourPacks),
    );
  }
}
).hasMatch(rawParent)) {
        throw const FormatException('Contour pack requires a valid base map ID');
      }
    } else if (rawParent != null) {
      throw const FormatException('A basemap cannot declare a contour parent');
    }

    final urlRaw = json['download_url'];
    Uri? url;
    if (urlRaw != null) {
      if (urlRaw is! String) throw const FormatException('Invalid pack URL');
      url = Uri.tryParse(urlRaw);
      if (url == null || url.scheme != 'https' || !url.hasAuthority ||
          url.userInfo.isNotEmpty || url.fragment.isNotEmpty ||
          !url.path.endsWith('.pmtiles')) {
        throw const FormatException('Map pack URL must be a direct HTTPS PMTiles file');
      }
    }
    final bytes = json['byte_length'];
    if (bytes != null && (bytes is! int || bytes <= 0 ||
        bytes > 2 * 1024 * 1024 * 1024)) {
      throw const FormatException('Invalid or excessive map pack size');
    }
    final hash = json['sha256'];
    if (hash != null && (hash is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash))) {
      throw const FormatException('Invalid SHA-256 fingerprint');
    }
    final approved = json['approved'] == true;
    if (approved && (url == null || bytes == null || hash == null)) {
      throw const FormatException('Approved map pack must pin source, bytes and SHA-256');
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
    );
  }
}

class RegionalMapCatalog {
  const RegionalMapCatalog(this.packs);

  final List<RegionalMapPack> packs;

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
      if (!ids.add(pack.id)) throw FormatException('Duplicate regional map pack: ${pack.id}');
      packs.add(pack);
    }
    return RegionalMapCatalog(List.unmodifiable(packs));
  }
}
