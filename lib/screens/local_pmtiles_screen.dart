import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/gpx_route.dart';
import '../services/gpx_library_service.dart';
import '../services/local_pmtiles_service.dart';

class LocalPmtilesScreen extends StatefulWidget {
  const LocalPmtilesScreen({super.key});

  @override
  State<LocalPmtilesScreen> createState() => _LocalPmtilesScreenState();
}

class _LocalPmtilesScreenState extends State<LocalPmtilesScreen> {
  final _service = const LocalPmtilesService();
  List<LocalPmtilesPack> _maps = const [];
  String? _error;
  bool _busy = false;
  bool _loading = true;
  int _received = 0;
  int _total = 0;

  bool get _en => Localizations.localeOf(context).languageCode == 'en';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final entries = await _service.list();
      if (!mounted) return;
      setState(() {
        _maps = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _en ? 'Unable to read local maps.' : 'Impossible de lire les cartes locales.';
      });
    }
  }

  Future<void> _import() async {
    if (_busy || kIsWeb) return;
    final en = _en;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(en ? 'Import a local map?' : 'Importer une carte locale ?'),
        content: Text(en
            ? 'Select a Protomaps v4 PMTiles regional extract (max 250 MiB). '
              'You need permission to use it. ReadySafe checks the file structure '
              'and hash, NOT its accuracy, licence, trail conditions or safety.'
            : 'Sélectionnez un extrait régional Protomaps v4 au format PMTiles '
              '(250 Mio maximum). Vous devez disposer des droits de l’utiliser. '
              'ReadySafe contrôle sa structure et son empreinte, PAS sa précision, '
              'sa licence, l’état des sentiers ni leur sécurité.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false),
            child: Text(en ? 'Cancel' : 'Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true),
            child: Text(en ? 'Choose file' : 'Choisir un fichier')),
        ],
      ),
    );
    if (!mounted || agreed != true) return;
    setState(() {
      _busy = true;
      _error = null;
      _received = 0;
      _total = 0;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pmtiles'],
      );
      if (file == null) return;
      if (!file.name.toLowerCase().endsWith('.pmtiles')) {
        throw const FormatException('Expected .pmtiles file');
      }
      final bytes = await file.length();
      await _service.importStream(
        file.readAsByteStream(),
        fileName: file.name,
        expectedBytes: bytes,
        onProgress: (done, total) {
          if (!mounted || (done - _received < 1024 * 1024 && done != total)) {
            return;
          }
          setState(() {
            _received = done;
            _total = total;
          });
        },
      );
      await _reload();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = en
          ? 'Import refused: please check Protomaps v4 layers, file size '
            '(250 MiB maximum) and available storage.'
          : 'Import refusé : contrôlez les couches Protomaps v4, la taille '
            '(250 Mio maximum) et l’espace libre.');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _received = 0;
          _total = 0;
        });
      }
    }
  }

  Future<void> _open(LocalPmtilesPack pack) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final style = await _service.style(pack);
      if (!mounted) return;
      await Navigator.of(context).push<void>(MaterialPageRoute(
        builder: (_) => _LocalPmtilesPreview(pack: pack, style: style),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _en
          ? 'The map is missing or has failed its SHA-256 integrity check.'
          : 'La carte est absente ou ne passe plus le contrôle d’intégrité SHA-256.');
      await _reload();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(LocalPmtilesPack pack) async {
    if (_busy) return;
    final en = _en;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(en ? 'Delete imported map?' : 'Supprimer la carte importée ?'),
        content: Text(en
            ? 'Only the ReadySafe copy is deleted, not your original file.'
            : 'Seule la copie ReadySafe sera supprimée, pas votre fichier original.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false),
            child: Text(en ? 'Cancel' : 'Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true),
            child: Text(en ? 'Delete' : 'Supprimer')),
        ],
      ),
    );
    if (!mounted || agreed != true) return;
    setState(() => _busy = true);
    try {
      await _service.delete(pack);
      await _reload();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = en ? 'Deletion failed.' : 'Suppression impossible.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = _en;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Imported offline maps' : 'Cartes hors ligne importées')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              Text(en ? 'MY LOCAL ATLAS' : 'MON ATLAS LOCAL',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900,
                  color: scheme.primary)),
              const SizedBox(height: 8),
              Text(en
                  ? 'Import Protomaps v4 PMTiles from your files. They are copied '
                    'to the app and can open in airplane mode, without an account.'
                  : 'Importez des fichiers PMTiles Protomaps v4 depuis le téléphone. '
                    'Ils restent accessibles en mode avion, sans compte.'),
              const SizedBox(height: 12),
              Card(
                color: scheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(en
                      ? 'Maps are unverified user-supplied data: no official '
                        'contours, safe routing, local labels or up-to-date hazards.'
                      : 'Cartes fournies par l’utilisateur et non certifiées : '
                        'pas de relief officiel, de guidage sûr, de noms locaux '
                        'ni d’informations actualisées sur les dangers.',
                    style: TextStyle(fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer)),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy || kIsWeb ? null : _import,
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(en ? 'Import PMTiles map' : 'Importer une carte PMTiles'),
              ),
              if (_busy && _total > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: (_received / _total).clamp(0.0, 1.0)),
                Text('${(_received / 1048576).toStringAsFixed(1)} / '
                    '${(_total / 1048576).toStringAsFixed(1)} Mio'),
              ],
              const SizedBox(height: 8),
              Text(en
                  ? '4 files maximum, 250 MiB each. Imported files never upload.'
                  : '4 fichiers maximum, 250 Mio chacun. Aucun transfert vers un serveur.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 22),
              Text(en ? 'Saved maps (${_maps.length})'
                      : 'Cartes enregistrées (${_maps.length})',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
              const SizedBox(height: 10),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_maps.isEmpty)
                Text(en
                    ? 'No map imported yet. Prepare a licensed Protomaps v4 regional extract first.'
                    : 'Aucune carte importée. Préparez d’abord un extrait régional Protomaps v4 autorisé.')
              else
                for (final pack in _maps)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pack.name, style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 17)),
                          const SizedBox(height: 5),
                          Text('${(pack.byteLength / 1048576).toStringAsFixed(1)} Mio'
                            ' · ${pack.latitude.toStringAsFixed(3)}, '
                            '${pack.longitude.toStringAsFixed(3)}'),
                          Text(LocalPmtilesPack.attribution, style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 12)),
                          const SizedBox(height: 9),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            FilledButton.tonalIcon(
                              onPressed: _busy ? null : () => _open(pack),
                              icon: const Icon(Icons.map_outlined),
                              label: Text(en ? 'Open offline' : 'Ouvrir hors ligne')),
                            TextButton.icon(
                              onPressed: _busy ? null : () => _delete(pack),
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: Text(en ? 'Delete' : 'Supprimer')),
                          ]),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalPmtilesPreview extends StatefulWidget {
  const _LocalPmtilesPreview({required this.pack, required this.style});
  final LocalPmtilesPack pack;
  final String style;

  @override
  State<_LocalPmtilesPreview> createState() => _LocalPmtilesPreviewState();
}

class _LocalPmtilesPreviewState extends State<_LocalPmtilesPreview> {
  MapLibreMapController? _map;

  Future<void> _showTracks() async {
    final map = _map;
    if (map == null || !mounted) return;
    try {
      final routes = await const GpxLibraryService().list();
      if (!mounted) return;
      for (final track in routes.where((r) => r.visible).take(8)) {
        for (final segment in GpxCodec.renderSegments(track,
            maximumVertices: 1000)) {
          if (!mounted) return;
          await map.addLine(LineOptions(
            geometry: [
              for (final p in segment) LatLng(p.latitude, p.longitude),
            ],
            lineColor: '#f97316',
            lineWidth: 4,
          ));
        }
        for (final p in track.waypoints.take(80)) {
          if (!mounted) return;
          await map.addCircle(CircleOptions(
            geometry: LatLng(p.latitude, p.longitude),
            circleRadius: 6,
            circleColor: '#f97316',
            circleStrokeColor: '#ffffff',
            circleStrokeWidth: 2,
          ));
        }
      }
    } catch (_) {
      // Malformed GPX overlays must never prevent a local basemap from opening.
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.pack.name)),
      body: Stack(children: [
        MapLibreMap(
          styleString: widget.style,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.pack.latitude, widget.pack.longitude),
            zoom: widget.pack.zoom,
          ),
          compassEnabled: true,
          onMapCreated: (map) => _map = map,
          onStyleLoadedCallback: _showTracks,
        ),
        Positioned(top: 10, left: 12, right: 12, child: IgnorePointer(
          child: Card(color: scheme.tertiaryContainer,
            child: Padding(padding: const EdgeInsets.all(10),
              child: Text(en
                  ? 'LOCAL PMTILES · Unverified trails · No contours or automatic routing'
                  : 'PMTILES LOCAL · Sentiers non vérifiés · Sans relief ni guidage automatique',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 12, color: scheme.onTertiaryContainer))))),
        ),
        Positioned(bottom: 16, left: 12, right: 12, child: IgnorePointer(
          child: Card(child: Padding(padding: const EdgeInsets.all(10),
            child: const Text(LocalPmtilesPack.attribution,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12))))),
        ),
      ]),
    );
  }
}
