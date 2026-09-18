import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../services/local_storage_service.dart';
import 'emergency_screen.dart';
import 'family_documents_screen.dart';
import 'first_aid_screen.dart';
import 'global_search_screen.dart';
import 'guided_emergency_screen.dart';
import 'online_maps_screen.dart';
import 'settings_screen.dart';
import 'survival_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = LocalStorageService();
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _refreshScore();
  }

  Future<void> _refreshScore() async {
    final value = await _storage.preparednessScore();
    if (mounted) setState(() => _score = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final country = app.activeCountry!;
    final en = Localizations.localeOf(context).languageCode == 'en';

    final modules = [
      _HomeModule(
        en ? 'First aid' : 'Premiers secours',
        en ? 'Visual guides and emergency mode' : 'Fiches visuelles et mode urgence',
        Icons.health_and_safety_rounded,
        const Color(0xffd92d36),
        const FirstAidScreen(),
      ),
      _HomeModule(
        en ? 'Kits & checklists' : 'Kit & check-lists',
        en ? 'Prepare equipment and essentials' : 'Équipement, stocks et préparation',
        Icons.backpack_rounded,
        const Color(0xffb7833f),
        const SurvivalHubScreen(),
      ),
      _HomeModule(
        en ? 'Family & documents' : 'Famille & documents',
        en ? 'Contacts, plans and vital documents' : 'Contacts, plan familial et documents',
        Icons.family_restroom_rounded,
        const Color(0xff087f83),
        const FamilyDocumentsScreen(),
      ),
      _HomeModule(
        en ? 'Map & landmarks' : 'Carte & repères',
        en ? 'Shelters, health, water and safe places' : 'Abris, santé, eau et lieux sûrs',
        Icons.map_rounded,
        const Color(0xff147343),
        const OnlineMapsScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshScore,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final padding = wide ? 26.0 : 14.0;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(padding, 14, padding, 28),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xff087f83),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ReadySafe', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                                Text(
                                  '${_flag(country.isoCode)} ${t.get(country.nameKey)}${app.travelMode ? ' · ✈' : ''}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xff65747a), fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: t.get('settings'),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                        ),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: en
                                  ? 'Search a gesture, risk, kit or place…'
                                  : 'Rechercher un geste, un risque, un kit ou un lieu…',
                              prefixIcon: const Icon(Icons.search_rounded),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EmergencyBanner(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GuidedEmergencyScreen()),
                        ),
                        onCall: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ScoreCard(score: _score),
                      const SizedBox(height: 18),
                      const Text('Essentiels', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 9),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: wide ? 2 : 2,
                          mainAxisExtent: wide ? 146 : 138,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) => _ModuleCard(module: modules[index]),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                            ),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickAction(
                            icon: Icons.phone_in_talk_rounded,
                            label: 'Numéros SOS',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                          ),
                          _QuickAction(
                            icon: Icons.favorite_rounded,
                            label: 'RCP adulte',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
                          ),
                          _QuickAction(
                            icon: Icons.map_rounded,
                            label: 'Repères',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineMapsScreen())),
                          ),
                          _QuickAction(
                            icon: Icons.offline_bolt_rounded,
                            label: 'Hors ligne',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Les fiches, kits, contacts et plans restent disponibles hors ligne.')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xffeaf6f4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Color(0xff087f83)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'ReadySafe rassemble urgence, premiers secours, préparation, famille et repères dans une seule app.',
                                style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _flag(String code) => String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}

class _EmergencyBanner extends StatelessWidget {
  const _EmergencyBanner({required this.onTap, required this.onCall});
  final VoidCallback onTap;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xffd92d36),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 15, 16, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0x22ffffff),
                      child: Icon(Icons.sos_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'URGENCE — GUIDEZ-MOI',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choisissez ce que vous observez et suivez le bon parcours.',
                            style: TextStyle(color: Colors.white, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x66ffffff)),
                  backgroundColor: const Color(0x16ffffff),
                ),
                onPressed: onCall,
                icon: const Icon(Icons.call_rounded),
                label: const Text('Voir les numéros d’urgence'),
              ),
            ),
          ],
        ),
      );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xffe7eeee),
                      color: const Color(0xff087f83),
                    ),
                    Text('$score', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Niveau de préparation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      score >= 75
                          ? 'Bon niveau. Continuez à vérifier vos informations.'
                          : score >= 40
                              ? 'Préparation en cours. Quelques essentiels restent à compléter.'
                              : 'Commencez par le kit, les contacts et le point de rassemblement.',
                      style: const TextStyle(color: Color(0xff65747a), height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _HomeModule {
  const _HomeModule(this.title, this.subtitle, this.icon, this.color, this.page);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _HomeModule module;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => module.page)),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffdbe6e7)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(module.icon, color: module.color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(
                        module.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, size: 18, color: const Color(0xff087f83)),
        label: Text(label),
        onPressed: onTap,
      );
}
