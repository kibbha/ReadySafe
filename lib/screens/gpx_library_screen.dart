import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show LatLng;

import '../models/gpx_route.dart';
import '../services/gpx_library_service.dart';

/// Imports, saves, previews, exports and deletes routes without a server.
/// Navigation to this page does not read current GPS coordinates.
class GpxLibraryScreen extends StatefulWidget {
  const GpxLibraryScreen({super.key});

  @override
  State<GpxLibraryScreen> createState() => _GpxLibraryScreenState();
}

class _GpxLibraryScreenState extends State<GpxLibraryScreen> {
  final _library = const GpxLibraryService();
  List<GpxRoute> _routes = const [];
  String? _error;
  bool _loading = true;
  bool _busy = false;

  bool get _english => Localizations.localeOf(context).languageCode == 'en';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final items = await _library.list();
      if (!mounted) return;
      setState(() {
        _routes = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _english
            ? 'Unable to read stored GPX traces.'
            : 'Impossible de lire les traces GPX enregistrées.';
      });
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final item = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
      );
      if (item == null) return;
      if (!item.name.toLowerCase().endsWith('.gpx')) {
        throw const FormatException('Unsupported file extension');
      }
      final size = await item.length();
      if (size <= 0 || size > GpxRoute.maxBytes) {
        throw const FormatException('The GPX file exceeds the 2 MiB limit');
      }
      final bytes = await item.readAsBytes();
      if (bytes.length > GpxRoute.maxBytes) {
        throw const FormatException('The GPX file exceeds the 2 MiB limit');
      }
      await _library.importBytes(bytes, item.name);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _english
            ? 'Import failed. Choose a valid GPX file smaller than 2 MiB (max 12,000 points).'
            : 'Import impossible. Choisissez un GPX valide de moins de 2 Mio (12 000 points maximum).';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _visibility(GpxRoute route, bool visible) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _library.setVisibility(route, visible);
      await _refresh();
    } catch (_) {
      if (mounted) {
        setState(() => _error = _english
            ? 'Could not update route visibility.'
            : 'Impossible de modifier l’affichage de la trace.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export(GpxRoute route) async {
    try {
      final xml = GpxCodec.encode(route);
      final bytes = Uint8List.fromList(utf8.encode(xml));
      final saved = await FilePicker.saveFile(
        fileName: '${route.id}.gpx',
        bytes: bytes,
        mimeType: 'application/gpx+xml',
        dialogTitle: _english
            ? 'Save GPX route on your device'
            : 'Enregistrer le parcours GPX',
      );
      if (!mounted || saved == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_english
              ? 'GPX file saved to the selected location.'
              : 'Fichier GPX enregistré à l’emplacement choisi.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _english
          ? 'Unable to save the GPX file.'
          : 'Impossible d’enregistrer le fichier GPX.');
    }
  }

  Future<void> _delete(GpxRoute route) async {
    final en = _english;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(en ? 'Delete this GPX trace?' : 'Supprimer cette trace GPX ?'),
        content: Text(en
            ? 'The locally saved copy will be deleted from ReadySafe. The original imported file is not affected.'
            : 'La copie locale sera supprimée de ReadySafe. Le fichier d’origine ne sera pas modifié.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(en ? 'Delete' : 'Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await _library.delete(route);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = en
          ? 'Could not delete the trace.'
          : 'Impossible de supprimer la trace.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = _english;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'GPX routes and waypoints' : 'Traces et repères GPX'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            children: [
              Text(en ? 'MY OFFLINE ROUTES' : 'MES TRACES HORS LIGNE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(en
                  ? 'Import GPX routes, tracks and waypoints from your device. '
                    'They are saved locally, even when no network is available.'
                  : 'Importez vos itinéraires, traces et repères GPX depuis le téléphone. '
                    'Ils restent enregistrés localement, même sans réseau.'),
              const SizedBox(height: 12),
              Card(
                color: scheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(en
                      ? 'A GPX trace is not a verified safe trail. It can lead to cliffs, closed paths or dangerous terrain. '
                        'Only follow routes you have independently checked.'
                      : 'Une trace GPX ne garantit PAS un chemin praticable : elle peut traverser falaises, sentiers fermés ou terrains dangereux. '
                        'Vérifiez chaque itinéraire indépendamment.',
                    style: TextStyle(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _import,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.file_upload_outlined),
                label: Text(en ? 'Import GPX file' : 'Importer un fichier GPX'),
              ),
              const SizedBox(height: 8),
              Text(en
                  ? 'Files: 2 MiB, 12,000 points and 500 waypoints. Up to eight visible tracks are rendered at once. No background tracking.'
                  : 'Fichiers : 2 Mio, 12 000 points et 500 repères. Huit traces visibles maximum sont dessinées simultanément. Aucun suivi GPS automatique.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 22),
              Text(en ? 'My saved traces (${_routes.length})'
                      : 'Mes traces enregistrées (${_routes.length})',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
              const SizedBox(height: 10),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_routes.isEmpty)
                Text(en
                    ? 'No local GPX trace yet. Import a route or waypoints from a trusted source.'
                    : 'Aucune trace GPX. Importez un itinéraire ou des repères d’une source fiable.')
              else
                for (final route in _routes)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: route.visible,
                            onChanged: _busy ? null : (v) => _visibility(route, v),
                            title: Text(route.name,
                              style: const TextStyle(fontWeight: FontWeight.w900)),
                            subtitle: Text(en
                                ? '${route.pointCount} route points · ${route.waypoints.length} waypoints · ${(route.lengthMeters / 1000).toStringAsFixed(2)} km'
                                : '${route.pointCount} points · ${route.waypoints.length} repères · ${(route.lengthMeters / 1000).toStringAsFixed(2)} km'),
                            secondary: Icon(Icons.route_rounded, color: scheme.primary),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              OutlinedButton.icon(
                                onPressed: route.firstPoint == null ? null : () async {
                                  if (!route.visible) {
                                    try {
                                      await _library.setVisibility(route, true);
                                    } catch (_) {
                                      if (!mounted) return;
                                      setState(() => _error = en
                                          ? 'Unable to show this trace on the map.'
                                          : 'Impossible d’afficher cette trace sur la carte.');
                                      return;
                                    }
                                  }
                                  if (!mounted) return;
                                  final point = route.firstPoint!;
                                  Navigator.pop(
                                    context,
                                    LatLng(point.latitude, point.longitude),
                                  );
                                },
                                icon: const Icon(Icons.map_outlined),
                                label: Text(en ? 'Show on map' : 'Voir sur la carte'),
                              ),
                              TextButton.icon(
                                onPressed: () => _export(route),
                                icon: const Icon(Icons.ios_share_rounded),
                                label: Text(en ? 'Export' : 'Exporter'),
                              ),
                              TextButton.icon(
                                onPressed: _busy ? null : () => _delete(route),
                                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                                label: Text(en ? 'Delete' : 'Supprimer'),
                              ),
                            ],
                          ),
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
