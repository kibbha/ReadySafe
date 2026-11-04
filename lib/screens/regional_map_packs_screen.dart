import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/regional_map_pack.dart';
import '../services/regional_map_pack_service.dart';

/// Regional PMTiles catalog. Nothing downloads without an approved pinned pack.
class RegionalMapPacksScreen extends StatefulWidget {
  const RegionalMapPacksScreen({super.key});

  @override
  State<RegionalMapPacksScreen> createState() => _RegionalMapPacksScreenState();
}

class _RegionalMapPacksScreenState extends State<RegionalMapPacksScreen> {
  final _service = const RegionalMapPackService();
  late Future<List<_PackStatus>> _future = _load();
  String? _activeId;
  String? _error;
  int _received = 0;
  int _total = 0;

  bool get _en => Localizations.localeOf(context).languageCode == 'en';

  Future<List<_PackStatus>> _load() async {
    final catalog = await _service.catalog();
    final result = <_PackStatus>[];
    for (final pack in catalog.packs) {
      final verified = await _service.verifiedInstalled(pack);
      result.add(_PackStatus(pack, verified));
    }
    return result;
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  Future<void> _download(RegionalMapPack pack) async {
    if (!pack.canDownload || _activeId != null || kIsWeb) return;
    final en = _en;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(en ? 'Download map pack?' : 'Télécharger le pack régional ?'),
        content: Text(en
            ? 'The region is saved only after its size and SHA-256 fingerprint match the approved catalog. Download over Wi-Fi if possible.'
            : 'Le pack sera enregistré seulement si sa taille et son empreinte SHA-256 correspondent au catalogue validé. Utilisez de préférence le Wi-Fi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(en ? 'Download' : 'Télécharger'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _activeId = pack.id;
      _received = 0;
      _total = pack.byteLength ?? 0;
      _error = null;
    });
    try {
      await _service.download(
        pack,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = _en
            ? 'Could not install this pack. Check network, storage and source validity.'
            : 'Installation impossible. Vérifiez le réseau, l’espace et la validité de la source.');
      }
    } finally {
      if (mounted) {
        setState(() => _activeId = null);
        _reload();
      }
    }
  }

  Future<void> _openPack(RegionalMapPack pack) async {
    if (kIsWeb) return;
    try {
      final style = await _service.localPreviewStyle(pack);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _LocalMapPreview(pack: pack, style: style),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _en
          ? 'Local pack is missing or corrupt. Redownload it.'
          : 'Le pack local est absent ou endommagé. Téléchargez-le à nouveau.');
      _reload();
    }
  }

  Future<void> _delete(RegionalMapPack pack) async {
    final en = _en;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(en ? 'Remove regional map?' : 'Supprimer la carte régionale ?'),
        content: Text(en
            ? 'This removes the offline archive from this device.'
            : 'Cette action supprime le fichier cartographique de cet appareil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(en ? 'Cancel' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(en ? 'Remove' : 'Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await _service.delete(pack);
      _reload();
    } catch (_) {
      if (mounted) {
        setState(() => _error = en
            ? 'Unable to remove the local archive.'
            : 'Impossible de supprimer le fichier local.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = _en;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Regional offline maps' : 'Cartes régionales hors ligne')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<List<_PackStatus>>(
            future: _future,
            builder: (context, snapshot) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  Text(
                    en ? 'YOUR SURVIVAL ATLAS' : 'VOTRE ATLAS DE SURVIE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(en
                      ? 'Regional archives will contain vector map data stored on the phone. Satellite signal may work without Internet, but routing and emergency services are not supplied by these packs.'
                      : 'Les cartes vectorielles seront conservées sur votre téléphone. Le GPS peut fonctionner sans Internet, mais ces packs ne fournissent pas encore de calcul d’itinéraire ni de secours.'),
                  const SizedBox(height: 12),
                  Card(
                    color: scheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        en
                            ? 'Catalog pilot: no regional source has passed licensing, checksum and field validation yet. Downloads stay disabled until a genuine dataset is approved.'
                            : 'Catalogue pilote : aucune source régionale n’a encore été validée (licence, empreinte et tests terrain). Les téléchargements restent désactivés jusqu’à homologation des données.',
                        style: TextStyle(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: 14),
                  if (!snapshot.hasData && !snapshot.hasError)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    Text(en
                        ? 'Unable to read the bundled regional map catalog.'
                        : 'Impossible de lire le catalogue régional embarqué.')
                  else
                    for (final item in snapshot.data!)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.terrain_rounded, color: scheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(
                                    item.pack.name(en),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                                  )),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item.installed
                                  ? (en ? 'Verified on device' : 'Intégrité vérifiée sur l’appareil')
                                  : item.pack.canDownload
                                      ? (en ? 'Available to download' : 'Disponible au téléchargement')
                                      : (en ? 'Coming soon — not hosted' : 'En préparation — non hébergé')),
                              const SizedBox(height: 4),
                              Text(item.pack.sourceLabel,
                                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                              Text(item.pack.attribution,
                                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                              if (_activeId == item.pack.id) ...[
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: _total <= 0 ? null : (_received / _total).clamp(0.0, 1.0),
                                ),
                                const SizedBox(height: 6),
                                Text(en
                                    ? '${(_received / 1000000).toStringAsFixed(1)} / ${(_total / 1000000).toStringAsFixed(1)} MB'
                                    : '${(_received / 1000000).toStringAsFixed(1)} / ${(_total / 1000000).toStringAsFixed(1)} Mo'),
                              ],
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    icon: Icon(item.installed
                                        ? Icons.map_rounded : Icons.download_rounded),
                                    label: Text(item.installed
                                        ? (en ? 'Open offline map' : 'Ouvrir la carte')
                                        : (en ? 'Download pack' : 'Télécharger le pack')),
                                    onPressed: _activeId == null && !kIsWeb &&
                                            (item.installed || item.pack.canDownload)
                                        ? () => item.installed
                                            ? _openPack(item.pack)
                                            : _download(item.pack)
                                        : null,
                                  ),
                                  if (item.installed)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      label: Text(en ? 'Remove' : 'Supprimer'),
                                      onPressed: _activeId == null
                                          ? () => _delete(item.pack)
                                          : null,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  Text(
                    en
                        ? 'A local map preview is not a certified hiking, avalanche or rescue map. Verify coverage, route conditions and phone battery before departure.'
                        : 'Une carte locale n’est pas une carte de randonnée, avalanche ou secours certifiée. Contrôlez la couverture, les conditions et la batterie avant le départ.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PackStatus {
  const _PackStatus(this.pack, this.installed);
  final RegionalMapPack pack;
  final bool installed;
}

class _LocalMapPreview extends StatelessWidget {
  const _LocalMapPreview({required this.pack, required this.style});

  final RegionalMapPack pack;
  final String style;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      appBar: AppBar(title: Text(pack.name(en))),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: style,
            initialCameraPosition: CameraPosition(
              target: LatLng(pack.centreLat, pack.centreLon),
              zoom: pack.zoom,
            ),
            compassEnabled: true,
            rotateGesturesEnabled: true,
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(en
                    ? 'OFFLINE PREVIEW · paths and terrain contour layers not yet verified'
                    : 'APERÇU HORS LIGNE · sentiers et relief non encore validés',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(pack.attribution, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
