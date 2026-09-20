import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/localizations.dart';
import '../services/local_storage_service.dart';
import 'emergency_screen.dart';
import 'family_documents_screen.dart';
import 'first_aid_screen.dart';
import 'global_search_screen.dart';
import 'guided_emergency_screen.dart';
import 'online_maps_screen.dart';
import 'preparedness_review_screen.dart';
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

  Future<void> _open(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    await _refreshScore();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final country = app.activeCountry!;
    final en = Localizations.localeOf(context).languageCode == 'en';
    final scheme = Theme.of(context).colorScheme;
    final emergencyNumber = country.preferredEmergencyNumber;

    final primaryActions = <_HomeAction>[
      _HomeAction(
        title: en ? 'A person is in danger' : 'Une personne est en danger',
        subtitle: en
            ? 'Unresponsive, not breathing, choking, bleeding or suddenly unwell.'
            : 'Inconsciente, ne respire pas, s’étouffe, saigne ou fait un malaise.',
        icon: Icons.health_and_safety_rounded,
        color: scheme.error,
        page: const GuidedEmergencyScreen(),
        urgent: true,
      ),
      _HomeAction(
        title: en ? 'I need to protect myself' : 'Je dois me protéger',
        subtitle: en
            ? 'Fire, evacuation, severe weather, outage, gas or other hazard.'
            : 'Incendie, évacuation, météo sévère, panne, gaz ou autre danger.',
        icon: Icons.shield_rounded,
        color: ReadySafeColors.aed,
        page: const GuidedEmergencyScreen(),
      ),
      _HomeAction(
        title: en ? 'I need a useful place' : 'Je cherche un lieu utile',
        subtitle: en
            ? 'AED, hospital, pharmacy, police, water or a saved landmark.'
            : 'DAE, hôpital, pharmacie, police, eau ou repère enregistré.',
        icon: Icons.near_me_rounded,
        color: scheme.primary,
        page: const OnlineMapsScreen(),
      ),
      _HomeAction(
        title: en ? 'I want to get prepared' : 'Je veux me préparer',
        subtitle: en
            ? '72-hour kit, checklists, household readiness and supplies.'
            : 'Kit 72 h, check-lists, préparation du foyer et réserves.',
        icon: Icons.backpack_rounded,
        color: scheme.secondary,
        page: const SurvivalHubScreen(),
      ),
    ];

    final shortcuts = <_HomeAction>[
      _HomeAction(
        title: en ? 'First-aid guides' : 'Gestes qui sauvent',
        subtitle: en
            ? 'Complete guides, guided mode and printable sheets.'
            : 'Fiches complètes, mode guidé et versions imprimables.',
        icon: Icons.volunteer_activism_rounded,
        color: scheme.error,
        page: const FirstAidScreen(),
      ),
      _HomeAction(
        title: en ? 'Family & documents' : 'Famille & documents',
        subtitle: en
            ? 'Contacts, plans and vital information stored on the device.'
            : 'Contacts, plans et informations essentielles stockées sur l’appareil.',
        icon: Icons.family_restroom_rounded,
        color: scheme.secondary,
        page: const FamilyDocumentsScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshScore,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final padding = width >= 760 ? 26.0 : 14.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(padding, 14, padding, 100),
                    children: [
                      _TopBar(
                        countryLabel:
                            '${_flag(country.isoCode)} ${t.get(country.nameKey)}${app.travelMode ? ' · ✈' : ''}',
                        verified: country.hasVerifiedNumbers,
                        en: en,
                        onSettings: () => _open(const SettingsScreen()),
                      ),
                      const SizedBox(height: 14),
                      _SearchLauncher(
                        en: en,
                        onTap: () => _open(const GlobalSearchScreen()),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        en ? 'WHAT IS HAPPENING?' : 'QUE SE PASSE-T-IL ?',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: width < 380 ? 25 : 30,
                          height: 1.0,
                          letterSpacing: -.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        en
                            ? 'Choose the closest situation. ReadySafe takes you straight to the useful action.'
                            : 'Choisissez la situation la plus proche. ReadySafe vous conduit directement vers l’action utile.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EmergencyStrip(
                        en: en,
                        number: emergencyNumber,
                        onNumbers: () => _open(const EmergencyScreen()),
                      ),
                      const SizedBox(height: 12),
                      _ActionWrap(
                        actions: primaryActions,
                        maxWidth: width,
                        onOpen: _open,
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        icon: Icons.bolt_rounded,
                        text: en ? 'Quick access' : 'Accès rapide',
                      ),
                      const SizedBox(height: 9),
                      _ActionWrap(
                        actions: shortcuts,
                        maxWidth: width,
                        onOpen: _open,
                        compact: true,
                      ),
                      const SizedBox(height: 14),
                      _ScoreCard(
                        score: _score,
                        en: en,
                        onTap: () => _open(
                          const PreparednessReviewScreen(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OfflineNotice(en: en),
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

  String _flag(String code) =>
      String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.countryLabel,
    required this.verified,
    required this.en,
    required this.onSettings,
  });

  final String countryLabel;
  final bool verified;
  final bool en;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            color: scheme.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ReadySafe',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      countryLabel,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    verified
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                    size: 16,
                    color: verified ? scheme.secondary : ReadySafeColors.aed,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: en ? 'Settings' : 'Paramètres',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _SearchLauncher extends StatelessWidget {
  const _SearchLauncher({
    required this.en,
    required this.onTap,
  });

  final bool en;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: en ? 'Open ReadySafe search' : 'Ouvrir la recherche ReadySafe',
        child: GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: en
                    ? 'Describe a symptom, risk, kit or place…'
                    : 'Décrire un symptôme, un risque, un kit ou un lieu…',
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
      );
}

class _EmergencyStrip extends StatelessWidget {
  const _EmergencyStrip({
    required this.en,
    required this.number,
    required this.onNumbers,
  });

  final bool en;
  final String? number;
  final VoidCallback onNumbers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onNumbers,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
          child: Row(
            children: [
              Icon(
                Icons.call_rounded,
                color: scheme.onErrorContainer,
                size: 27,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  number == null
                      ? (en
                          ? 'Immediate danger · open verified emergency numbers'
                          : 'Danger immédiat · ouvrir les numéros d’urgence vérifiés')
                      : (en
                          ? 'Immediate danger · emergency medical number $number'
                          : 'Danger immédiat · urgence médicale $number'),
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onErrorContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionWrap extends StatelessWidget {
  const _ActionWrap({
    required this.actions,
    required this.maxWidth,
    required this.onOpen,
    this.compact = false,
  });

  final List<_HomeAction> actions;
  final double maxWidth;
  final Future<void> Function(Widget page) onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final columns = maxWidth >= 900
        ? 2
        : maxWidth >= 620
            ? 2
            : 1;
    const gap = 10.0;
    final available = maxWidth > 1080 ? 1080.0 : maxWidth;
    final itemWidth =
        columns == 1 ? available : (available - gap) / columns;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final action in actions)
          SizedBox(
            width: itemWidth,
            child: _ActionCard(
              action: action,
              compact: compact,
              onTap: () => onOpen(action.page),
            ),
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.action,
    required this.compact,
    required this.onTap,
  });

  final _HomeAction action;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.all(compact ? 13 : 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 47 : 54,
                height: compact ? 47 : 54,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: compact ? 25 : 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (action.urgent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'en'
                              ? 'ACT NOW'
                              : 'AGIR MAINTENANT',
                          style: TextStyle(
                            color: scheme.error,
                            fontSize: 10.5,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: compact ? 16 : 18,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: compact ? 12 : 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: action.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 21,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.en,
    required this.onTap,
  });

  final int score;
  final bool en;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: scheme.secondary,
                    ),
                    Text(
                      '$score',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      en ? 'Preparedness level' : 'Niveau de préparation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      en
                          ? (score >= 75
                              ? 'Good level. Keep information and supplies up to date.'
                              : score >= 40
                                  ? 'Preparedness is progressing. A few essentials still need attention.'
                                  : 'Start with the kit, contacts and meeting point.')
                          : (score >= 75
                              ? 'Bon niveau. Gardez les informations et réserves à jour.'
                              : score >= 40
                                  ? 'La préparation progresse. Quelques essentiels restent à compléter.'
                                  : 'Commencez par le kit, les contacts et le point de rassemblement.'),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.en});

  final bool en;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.offline_bolt_rounded,
            color: scheme.secondary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              en
                  ? 'Life-saving guides, emergency numbers and preparedness essentials remain available without Internet.'
                  : 'Les gestes qui sauvent, numéros d’urgence et essentiels de préparation restent disponibles sans Internet.',
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
    this.urgent = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final bool urgent;
}
