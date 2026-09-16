import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../models/map_pack.dart';
import '../services/map_pack_service.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key, this.provider});
  final OfflineMapProvider? provider;
  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  late final OfflineMapProvider provider =
      widget.provider ?? UnconfiguredOfflineMapProvider();
  late Future<List<MapPack>> packs;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    packs = provider.catalog(AppScope.of(context).activeCountry!.isoCode);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('maps'))),
      body: ListView(
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
                    t.get('map_provider_missing'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(t.get('map_policy')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.get('map_architecture'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          FutureBuilder<List<MapPack>>(
            future: packs,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: snapshot.data!
                    .map((pack) => _MapPackCard(pack: pack, provider: provider))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapPackCard extends StatelessWidget {
  const _MapPackCard({required this.pack, required this.provider});
  final MapPack pack;
  final OfflineMapProvider provider;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final installed = pack.state == MapPackState.installed;
    final available = pack.state == MapPackState.available;
    final status = installed
        ? t.get('map_installed')
        : available
        ? t.get('map_available')
        : t.get('map_unavailable');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.map_outlined),
              title: Text(
                '${AppScope.of(context).activeCountry!.isoCode} — ${pack.name}',
              ),
              subtitle: Text('$status\n${t.get('map_license')}'),
              isThreeLine: true,
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: available
                      ? () => provider.download(pack.id, (_) {})
                      : null,
                  icon: const Icon(Icons.download),
                  label: Text(t.get('download')),
                ),
                OutlinedButton.icon(
                  onPressed: installed
                      ? () => provider.localStyleUri(pack.id)
                      : null,
                  icon: const Icon(Icons.map),
                  label: Text(t.get('view')),
                ),
                TextButton.icon(
                  onPressed: installed ? () => provider.delete(pack.id) : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(t.get('delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
