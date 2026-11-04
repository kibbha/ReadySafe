import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/field_guide_repository.dart';
import '../models/field_guide_entry.dart';

/// Bundled field knowledge: everything on this screen works in airplane mode.
class FieldGuideScreen extends StatefulWidget {
  const FieldGuideScreen({super.key});

  @override
  State<FieldGuideScreen> createState() => _FieldGuideScreenState();
}

class _FieldGuideScreenState extends State<FieldGuideScreen> {
  final _search = TextEditingController();
  late final Future<List<FieldGuideEntry>> _database = FieldGuideRepository.load();
  FieldGuideCategory? _category;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Survival field guide' : 'Encyclopédie de survie')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: FutureBuilder<List<FieldGuideEntry>>(
              future: _database,
              builder: (context, snapshot) {
                final entries = snapshot.data ?? const <FieldGuideEntry>[];
                final visible = FieldGuideRepository.search(
                  entries,
                  query: _search.text,
                  category: _category,
                  english: en,
                );
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    Text(
                      en ? 'KNOW BEFORE YOU NEED IT' : 'SAVOIR AVANT D’EN AVOIR BESOIN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      en
                          ? 'Plants, fungi and practical wilderness skills. This starter collection is built into ReadySafe and needs no connection.'
                          : 'Plantes, champignons et gestes de terrain. Cette première collection est intégrée à ReadySafe et ne nécessite aucune connexion.',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: scheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                en
                                    ? 'NEVER eat a wild plant or mushroom, or prepare medicine, based on this guide. Mushroom harvests must be inspected by a qualified expert. Pilot entries still require specialist editorial review.'
                                    : 'Ne JAMAIS consommer une plante ou un champignon sauvage, ni fabriquer un remède, sur la seule base de ce guide. Toute récolte de champignons doit être contrôlée par un spécialiste. Ces fiches pilotes restent à valider.',
                                style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: en ? 'Search an item or technique' : 'Rechercher une espèce ou une technique',
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: en ? 'Clear' : 'Effacer',
                                onPressed: _search.clear,
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilterChip(
                          label: Text(en ? 'All' : 'Tout'),
                          selected: _category == null,
                          onSelected: (_) => setState(() => _category = null),
                        ),
                        for (final category in FieldGuideCategory.values)
                          FilterChip(
                            label: Text(_categoryLabel(category, en)),
                            selected: _category == category,
                            onSelected: (_) => setState(() => _category = category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.hasError)
                      Text(en ? 'Unable to read the local knowledge pack.' : 'Impossible de lire la bibliothèque locale.')
                    else if (!snapshot.hasData)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ))
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          en ? '${visible.length} offline entries' : '${visible.length} fiches hors ligne',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Text(en ? 'No matching entries.' : 'Aucune fiche correspondante.'),
                        ),
                      for (final entry in visible)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: scheme.secondaryContainer,
                              child: Icon(_icon(entry.category), color: scheme.onSecondaryContainer),
                            ),
                            title: Text(entry.title(en), style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text([
                                if (entry.scientificName.isNotEmpty) entry.scientificName,
                                entry.summary(en),
                              ].join(' · '), maxLines: 3, overflow: TextOverflow.ellipsis),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => _FieldGuideDetail(entry: entry)),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(FieldGuideCategory category, bool en) {
  return switch (category) {
    FieldGuideCategory.plants => en ? 'Plants' : 'Plantes',
    FieldGuideCategory.mushrooms => en ? 'Mushrooms' : 'Champignons',
    FieldGuideCategory.skills => en ? 'Techniques' : 'Techniques',
  };
}

IconData _icon(FieldGuideCategory category) => switch (category) {
  FieldGuideCategory.plants => Icons.eco_rounded,
  FieldGuideCategory.mushrooms => Icons.park_rounded,
  FieldGuideCategory.skills => Icons.handyman_rounded,
};

class _FieldGuideDetail extends StatelessWidget {
  const _FieldGuideDetail({required this.entry});

  final FieldGuideEntry entry;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final scheme = Theme.of(context).colorScheme;
    final scientific = entry.scientificName;
    final isSpecies = entry.category != FieldGuideCategory.skills;
    return Scaffold(
      appBar: AppBar(title: Text(entry.title(en))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    Icon(_icon(entry.category), color: scheme.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_categoryLabel(entry.category, en),
                      style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(entry.title(en),
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                if (scientific.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(scientific, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                ],
                const SizedBox(height: 14),
                Text(entry.summary(en), style: const TextStyle(fontSize: 16, height: 1.4)),
                const SizedBox(height: 18),
                Card(
                  color: isSpecies ? scheme.errorContainer : scheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.gpp_maybe_rounded,
                          color: isSpecies ? scheme.onErrorContainer : scheme.onTertiaryContainer),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.warning(en),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isSpecies ? scheme.onErrorContainer : scheme.onTertiaryContainer,
                          ))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isSpecies
                      ? (en ? 'Observation and precautions' : 'Observation et précautions')
                      : (en ? 'Step-by-step' : 'Étapes pratiques'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < entry.steps(en).length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 13, child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.steps(en)[i], style: const TextStyle(height: 1.35))),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                Text(en ? 'Reference and editorial status' : 'Référence et statut éditorial',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  en
                      ? 'Pilot content awaiting qualified review. Reference links require internet; the entry itself is offline.'
                      : 'Contenu pilote en attente de relecture spécialisée. La référence nécessite Internet, la fiche reste disponible hors ligne.',
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(entry.sourceLabel),
                  onPressed: () => launchUrl(Uri.parse(entry.sourceUrl), mode: LaunchMode.externalApplication),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
