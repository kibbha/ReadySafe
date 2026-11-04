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
  });

  final String id, nameFr, nameEn, country, tileSchema;
  final String attribution, license, sourceLabel, version;
  final double centreLat, centreLon, zoom;
  final Uri? downloadUrl;
  final int? byteLength;
  final String? sha256Hex;
  final bool approved;

  String name(bool english) => english ? nameEn : nameFr;

  bool get canDownload =>
      approved &&
      downloadUrl != null &&
      byteLength != null &&
      byteLength! > 0 &&
      sha256Hex != null &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256Hex!) &&
      tileSchema == 'protomaps-v4';

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
    if (schema != 'protomaps-v4') {
      throw const FormatException('Unsupported map tile schema');
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
