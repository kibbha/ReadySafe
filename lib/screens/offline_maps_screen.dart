import 'package:flutter/material.dart';
import '../app/localizations.dart';
import '../models/map_pack.dart';
import '../services/map_pack_service.dart';
import '../widgets/country_picker.dart';

enum MapPackFilter { all, europe, downloaded }

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key, this.provider});
  final OfflineMapProvider? provider;
  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  late final OfflineMapProvider provider =
      widget.provider ?? UnconfiguredOfflineMapProvider();
  late Future<List<MapPack>> packs = provider.catalog(null);
  final Map<String, double> progress = {};
  String query = '';
  MapPackFilter filter = MapPackFilter.all;
  void _reload(String id) => setState(() {
    progress.remove(id);
    packs = provider.catalog(null);
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('maps'))),
      body: FutureBuilder<List<MapPack>>(
        future: packs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final visible = snapshot.data!.where((pack) {
            final name = strings.get(pack.nameKey).toLowerCase();
            final matches =
                name.contains(query.toLowerCase()) ||
                pack.countryCode.toLowerCase().contains(query.toLowerCase());
            return matches &&
                (filter != MapPackFilter.downloaded || pack.isInstalled);
          }).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.get('map_provider_missing'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(strings.get('map_policy')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SearchBar(
                hintText: strings.get('search_maps'),
                leading: const Icon(Icons.search),
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 10),
              SegmentedButton<MapPackFilter>(
                segments: [
                  ButtonSegment(
                    value: MapPackFilter.all,
                    label: Text(strings.get('all_filter')),
                  ),
                  ButtonSegment(
                    value: MapPackFilter.europe,
                    label: Text(strings.get('europe_filter')),
                  ),
                  ButtonSegment(
                    value: MapPackFilter.downloaded,
                    label: Text(strings.get('downloaded_filter')),
                  ),
                ],
                selected: {filter},
                onSelectionChanged: (value) =>
                    setState(() => filter = value.single),
              ),
              const SizedBox(height: 12),
              ...visible.map(
                (pack) => _MapPackCard(
                  pack: pack,
                  provider: provider,
                  progress: progress[pack.id],
                  onProgress: (value) =>
                      setState(() => progress[pack.id] = value),
                  onChanged: () => _reload(pack.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapPackCard extends StatelessWidget {
  const _MapPackCard({
    required this.pack,
    required this.provider,
    required this.onChanged,
    required this.onProgress,
    this.progress,
  });
  final MapPack pack;
  final OfflineMapProvider provider;
  final VoidCallback onChanged;
  final ValueChanged<double> onProgress;
  final double? progress;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stateKey = switch (pack.state) {
      MapPackState.available => 'map_available',
      MapPackState.downloading => 'map_downloading',
      MapPackState.paused => 'pause',
      MapPackState.installed => 'map_installed',
      MapPackState.updateAvailable => 'map_update',
      _ => 'map_unavailable',
    };
    final size = pack.estimatedBytes == null
        ? strings.get('size_unknown')
        : '${(pack.estimatedBytes! / 1048576).round()} MB';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                countryFlag(pack.countryCode),
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(strings.get(pack.nameKey)),
              subtitle: Text(
                '${strings.get(stateKey)} · $size\n${strings.get('map_license')}',
              ),
              isThreeLine: true,
            ),
            if (progress != null || pack.progress != null)
              LinearProgressIndicator(value: progress ?? pack.progress),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: pack.state == MapPackState.available
                      ? () async {
                          await provider.download(pack.id, onProgress);
                          onChanged();
                        }
                      : null,
                  icon: const Icon(Icons.download),
                  label: Text(strings.get('download')),
                ),
                if (pack.state == MapPackState.downloading)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await provider.pause(pack.id);
                      onChanged();
                    },
                    icon: const Icon(Icons.pause),
                    label: Text(strings.get('pause')),
                  ),
                if (pack.state == MapPackState.paused)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await provider.resume(pack.id, onProgress);
                      onChanged();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(strings.get('resume')),
                  ),
                if (pack.state == MapPackState.updateAvailable)
                  FilledButton.icon(
                    onPressed: () async {
                      await provider.download(pack.id, onProgress);
                      onChanged();
                    },
                    icon: const Icon(Icons.system_update),
                    label: Text(strings.get('map_update')),
                  ),
                OutlinedButton.icon(
                  onPressed: pack.isInstalled
                      ? () => provider.localStyleUri(pack.id)
                      : null,
                  icon: const Icon(Icons.map),
                  label: Text(strings.get('view')),
                ),
                TextButton.icon(
                  onPressed: pack.isInstalled
                      ? () async {
                          await provider.delete(pack.id);
                          onChanged();
                        }
                      : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(strings.get('delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
