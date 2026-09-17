import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../models/map_pack.dart';
import '../services/map_pack_service.dart';
import '../widgets/country_picker.dart';
import 'offline_map_viewer_screen.dart';

enum MapPackFilter { all, europe, downloaded }

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key, this.provider});
  final OfflineMapProvider? provider;

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  late final OfflineMapProvider provider = widget.provider ?? PmTilesOfflineMapProvider();
  late Future<List<MapPack>> packs = provider.catalog(null);
  final Map<String, double> progress = {};
  String query = '';
  MapPackFilter filter = MapPackFilter.all;

  void _reload(String id) => setState(() { progress.remove(id); packs = provider.catalog(null); });
  String _size(int bytes) => bytes >= 1073741824 ? '${(bytes / 1073741824).toStringAsFixed(1)} GB' : '${(bytes / 1048576).round()} MB';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('maps'))),
      body: FutureBuilder<List<MapPack>>(
        future: packs,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Impossible de charger le catalogue cartographique.\n${snapshot.error}', textAlign: TextAlign.center)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final all = snapshot.data!;
          final configured = all.where((p) => p.isConfigured).length;
          final installed = all.where((p) => p.isInstalled).toList();
          final installedBytes = installed.fold<int>(0, (sum, p) => sum + (p.downloadedBytes ?? 0));
          final visible = all.where((pack) {
            final needle = query.toLowerCase();
            final matches = strings.get(pack.nameKey).toLowerCase().contains(needle) || pack.countryCode.toLowerCase().contains(needle);
            return matches && (filter != MapPackFilter.downloaded || pack.isInstalled);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xffe8f5f5), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.public, color: Color(0xff087f83))),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${all.length} pays européens', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  Text(configured == 0 ? 'Catalogue prêt · packs vérifiés à publier' : '$configured packs disponibles au téléchargement', style: const TextStyle(color: Color(0xff65747a))),
                ])),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(color: const Color(0xfff4f8f8), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xffe1e9ea))),
                child: Row(children: [
                  const Icon(Icons.offline_pin_outlined, color: Color(0xff087f83)),
                  const SizedBox(width: 9),
                  Expanded(child: Text(installed.isEmpty ? 'Aucune carte installée' : '${installed.length} carte${installed.length > 1 ? 's' : ''} installée${installed.length > 1 ? 's' : ''} · ${_size(installedBytes)}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  if (configured == 0) const Tooltip(message: 'Un pack apparaît téléchargeable uniquement avec URL HTTPS, taille et SHA-256 vérifiés.', child: Icon(Icons.verified_user_outlined, size: 20, color: Color(0xff65747a))),
                ]),
              ),
              const SizedBox(height: 12),
              SearchBar(hintText: strings.get('search_maps'), leading: const Icon(Icons.search), elevation: const WidgetStatePropertyAll(0), onChanged: (value) => setState(() => query = value)),
              const SizedBox(height: 10),
              SegmentedButton<MapPackFilter>(segments: [
                ButtonSegment(value: MapPackFilter.all, label: Text(strings.get('all_filter'))),
                ButtonSegment(value: MapPackFilter.europe, label: Text(strings.get('europe_filter'))),
                ButtonSegment(value: MapPackFilter.downloaded, label: Text(strings.get('downloaded_filter'))),
              ], selected: {filter}, showSelectedIcon: false, onSelectionChanged: (value) => setState(() => filter = value.single)),
              const SizedBox(height: 14),
              if (visible.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                const Icon(Icons.map_outlined, size: 40, color: Color(0xff87969a)), const SizedBox(height: 8),
                Text(filter == MapPackFilter.downloaded ? 'Aucune carte téléchargée' : 'Aucun pack disponible pour cette recherche', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
              ]))),
              ...visible.map((pack) => _MapPackCard(pack: pack, provider: provider, progress: progress[pack.id], onProgress: (value) => setState(() => progress[pack.id] = value), onChanged: () => _reload(pack.id))),
            ],
          );
        },
      ),
    );
  }
}

class _MapPackCard extends StatelessWidget {
  const _MapPackCard({required this.pack, required this.provider, required this.onChanged, required this.onProgress, this.progress});
  final MapPack pack;
  final OfflineMapProvider provider;
  final VoidCallback onChanged;
  final ValueChanged<double> onProgress;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final size = pack.estimatedBytes == null ? strings.get('size_unknown') : '${(pack.estimatedBytes! / 1048576).round()} MB';
    final installed = pack.isInstalled;
    final configured = pack.isConfigured;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        Row(children: [
          Text(countryFlag(pack.countryCode), style: const TextStyle(fontSize: 30)), const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(strings.get(pack.nameKey), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text(installed ? 'Carte disponible hors ligne' : configured ? '$size · OpenStreetMap' : 'Pack en préparation', style: TextStyle(fontSize: 12, color: installed ? const Color(0xff087f83) : const Color(0xff65747a), fontWeight: installed ? FontWeight.w700 : FontWeight.normal)),
          ])),
          if (installed)
            IconButton.filledTonal(tooltip: strings.get('view'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfflineMapViewerScreen(pack: pack))), icon: const Icon(Icons.map_outlined))
          else if (configured)
            FilledButton.tonal(onPressed: pack.state == MapPackState.available ? () async { try { await provider.download(pack.id, onProgress); onChanged(); } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Téléchargement impossible : $error'))); } } : null, child: const Icon(Icons.download))
          else
            const Tooltip(message: 'Archive PMTiles non publiée', child: Icon(Icons.schedule_outlined, color: Color(0xff87969a))),
        ]),
        if (progress != null || pack.progress != null) ...[const SizedBox(height: 9), LinearProgressIndicator(value: progress ?? pack.progress, minHeight: 7, borderRadius: BorderRadius.circular(6))],
        if (installed) Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton.icon(onPressed: () async { await provider.delete(pack.id); onChanged(); }, icon: const Icon(Icons.delete_outline, size: 18), label: Text(strings.get('delete')))]),
      ])),
    );
  }
}
