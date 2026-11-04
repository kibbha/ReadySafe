import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;

import '../services/offline_area_service.dart';

/// Manage small, bounded MapLibre cache regions. No country-wide bulk download.
class OfflineMapAreasScreen extends StatefulWidget {
  const OfflineMapAreasScreen({super.key, required this.centre});

  final maplibre.LatLng centre;

  @override
  State<OfflineMapAreasScreen> createState() => _OfflineMapAreasScreenState();
}

class _OfflineMapAreasScreenState extends State<OfflineMapAreasScreen> {
  final _service = const OfflineAreaService();

  List<OfflineAreaRecord> _areas = const [];
  bool _loading = true;
  bool _downloading = false;
  double? _progress;
  int _downloadedBytes = 0;
  String? _error;
  OfflineAreaDraft? _draft;

  bool get _english => Localizations.localeOf(context).languageCode == 'en';

  @override
  void initState() {
    super.initState();
    try {
      _draft = OfflineAreaPolicy.around(
        widget.centre.latitude,
        widget.centre.longitude,
      );
    } catch (error) {
      _error = error.toString();
    }
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final areas = kIsWeb ? const <OfflineAreaRecord>[] : await _service.list();
      if (!mounted) return;
      setState(() {
        _areas = areas;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _startDownload() async {
    if (_downloading || _draft == null || kIsWeb) return;
    final en = _english;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(en ? 'Save a small offline area?' : 'Enregistrer une petite zone hors ligne ?'),
        content: Text(en
            ? 'The map downloads around the current map centre within a 1.5 km radius, zoom 11–15. '
              'This is not a full hiking atlas, does not include offline routing and may not include terrain contours. '
              'Check the downloaded area in airplane mode before relying on it.'
            : 'La carte sera téléchargée autour du centre actuel (rayon 1,5 km, zooms 11 à 15). '
              'Ce n’est pas encore un atlas de randonnée complet : aucun itinéraire autonome ni relief garanti. '
              'Testez la zone en mode avion avant de compter dessus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(en ? 'Download' : 'Télécharger'),
          ),
        ],
      ),
    );
    if (!mounted || agreed != true) return;

    setState(() {
      _error = null;
      _progress = 0;
      _downloadedBytes = 0;
      _downloading = true;
    });

    int? regionId;
    bool overLimit = false;

    Future<void> discardOversize() async {
      if (regionId == null) return;
      try {
        await _service.delete(regionId!);
      } catch (_) {
        // A failed or already-removed region is not considered complete.
      }
      await _refresh();
    }

    try {
      final region = await _service.download(
        _draft!,
        onEvent: (event) {
          if (!mounted) return;
          if (event is maplibre.InProgress) {
            final bytes = event.completedResourceSize;
            if (bytes > OfflineAreaPolicy.maxBytes && !overLimit) {
              overLimit = true;
              setState(() {
                _downloading = false;
                _error = _english
                    ? 'Provider download cap exceeded: the region will be removed.'
                    : 'Limite de téléchargement dépassée : cette zone sera supprimée.';
              });
              discardOversize();
              return;
            }
            if (overLimit) return;
            setState(() {
              _downloadedBytes = bytes;
              _progress = event.requiredResourceCount > 0
                  ? (event.completedResourceCount / event.requiredResourceCount)
                      .clamp(0.0, 1.0)
                      .toDouble()
                  : null;
            });
          } else if (event is maplibre.Success) {
            if (overLimit) {
              discardOversize();
              return;
            }
            setState(() {
              _downloading = false;
              _progress = 1;
            });
            _refresh();
          } else if (event is maplibre.Error) {
            setState(() {
              _downloading = false;
              _error = _english
                  ? 'Offline area download failed. Retry while connected.'
                  : 'Échec du téléchargement. Réessayez avec une connexion.';
            });
            _refresh();
          }
        },
      );
      regionId = region.id;
      if (overLimit) {
        await discardOversize();
      } else {
        await _refresh();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = error.toString();
      });
      await _refresh();
    }
  }

  Future<void> _deleteArea(OfflineAreaRecord area) async {
    final en = _english;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(en ? 'Delete saved area?' : 'Supprimer la zone enregistrée ?'),
        content: Text(en
            ? 'You will need a connection to download it again.'
            : 'Il faudra une connexion pour la télécharger à nouveau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(en ? 'Delete' : 'Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;
    try {
      await _service.delete(area.region.id);
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = _english;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Offline map areas' : 'Zones cartographiques hors ligne')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(en ? 'SAVE THE AREA AROUND THE MAP' : 'ENREGISTRER LA ZONE DE LA CARTE',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
              const SizedBox(height: 10),
              Text(en
                ? 'Only small areas may be downloaded from this provider. '
                  'Full regional packs, contour lines and offline route calculation are separate V4 milestones.'
                : 'Ce fournisseur autorise uniquement des téléchargements limités. '
                  'Les cartes régionales, les courbes de niveau et les itinéraires hors ligne restent des étapes distinctes.'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(en ? 'Centre of the area' : 'Centre de la zone',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(_draft?.label ?? (en ? 'Unavailable' : 'Indisponible')),
                      const SizedBox(height: 4),
                      Text(en
                        ? 'Radius: 1.5 km · Zoom: 11–15'
                        : 'Rayon : 1,5 km · Zooms : 11 à 15'),
                      if (_draft != null) ...[
                        const SizedBox(height: 4),
                        Text(en
                          ? 'Estimated map tiles: ${_draft!.estimatedTiles} (limit: 3,000)'
                          : 'Tuiles estimées : ${_draft!.estimatedTiles} (limite : 3 000)'),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.download_rounded),
                        label: Text(en ? 'Save current area' : 'Télécharger la zone actuelle'),
                        onPressed: _draft == null || _downloading || kIsWeb
                            ? null
                            : _startDownload,
                      ),
                    ],
                  ),
                ),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                Text(en
                  ? 'Offline regions are available on Android and iOS only.'
                  : 'Les zones hors ligne sont disponibles uniquement sur Android et iOS.'),
              ],
              if (_downloading) ...[
                const SizedBox(height: 14),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 6),
                Text(en
                  ? 'Downloading · ${(_downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB received'
                  : 'Téléchargement · ${(_downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} Mo reçus'),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: Text(en ? 'Downloaded areas' : 'Zones enregistrées',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
                  IconButton(
                    tooltip: en ? 'Refresh' : 'Actualiser',
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_areas.isEmpty)
                Text(en
                  ? 'No verified complete offline area on this device.'
                  : 'Aucune zone hors ligne complète vérifiée sur cet appareil.')
              else
                for (final area in _areas)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        area.complete ? Icons.offline_pin_rounded : Icons.cloud_download_outlined,
                        color: area.complete ? scheme.primary : scheme.tertiary,
                      ),
                      title: Text(area.label),
                      subtitle: Text(area.complete
                          ? (en ? 'Downloaded · MapLibre cache' : 'Téléchargée · cache MapLibre')
                          : (en ? 'Incomplete or awaiting verification' : 'Incomplète ou à vérifier')),
                      onTap: area.complete ? () {
                        final bounds = area.region.definition.bounds;
                        Navigator.pop(
                          context,
                          maplibre.LatLng(
                            (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
                            (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
                          ),
                        );
                      } : null,
                      trailing: IconButton(
                        tooltip: en ? 'Delete' : 'Supprimer',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: _downloading ? null : () => _deleteArea(area),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              Text(OfflineAreaPolicy.attribution, style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              )),
              const SizedBox(height: 6),
              Text(en
                ? 'An offline saved region does not guarantee rescue, usable trails, routing, potable water, or GPS accuracy. Verify content before departure.'
                : 'Une zone sauvegardée ne garantit ni secours, ni sentiers praticables, ni calcul d’itinéraire, ni eau potable, ni précision GPS. Vérifiez avant le départ.',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
