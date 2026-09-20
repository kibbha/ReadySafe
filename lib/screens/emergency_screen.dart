import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../models/country_profile.dart';
import '../services/emergency_call_service.dart';
import 'official_sources_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, this.callService});
  final EmergencyCallService? callService;

  IconData _icon(EmergencyService service) {
    final key = '${service.id} ${service.nameKey}'.toLowerCase();
    if (key.contains('rega') || key.contains('air_rescue')) return Icons.flight_outlined;
    if (key.contains('police')) return Icons.local_police_outlined;
    if (key.contains('fire')) return Icons.local_fire_department_outlined;
    if (key.contains('ambulance') || key.contains('medical')) return Icons.emergency_outlined;
    if (key.contains('poison')) return Icons.science_outlined;
    if (key.contains('gas')) return Icons.warning_amber_outlined;
    if (key.contains('rescue')) return Icons.health_and_safety_outlined;
    if (key.contains('youth')) return Icons.child_care_outlined;
    if (key.contains('help')) return Icons.support_agent_outlined;
    return Icons.sos_outlined;
  }

  String _flag(String iso) {
    if (iso.length != 2) return '🌐';
    return String.fromCharCodes(iso.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 65));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final country = AppScope.of(context).activeCountry!;
    final caller = callService ?? DeviceEmergencyCallService();
    final callable = country.services.where((s) => s.isCallable).toList();
    EmergencyService? primary;
    for (final s in callable) {
      if (s.nameKey.contains('ambulance')) { primary = s; break; }
    }
    primary ??= callable.isEmpty ? null : callable.first;
    final others = primary == null ? callable : callable.where((s) => s != primary).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.get('emergencies'))),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(children: [
              Container(
                width: 54,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _flag(country.isoCode),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.get(country.nameKey), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                Text(
                  t.get('emergency_hint'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ])),
              Icon(
                country.hasVerifiedNumbers
                    ? Icons.verified_outlined
                    : Icons.info_outline_rounded,
                color: country.hasVerifiedNumbers
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.tertiary,
              ),
            ]),
          ),
          if (primary != null) ...[
            const SizedBox(height: 14),
            _DangerHero(
              service: primary,
              callService: caller,
            ),
          ] else ...[
            const SizedBox(height: 14),
            _UnverifiedCountryNotice(
              en: en,
              countryName: t.get(country.nameKey),
            ),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(en ? 'Useful numbers' : 'Numéros utiles', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale =
                    MediaQuery.textScalerOf(context).scale(16) / 16;
                final columns = textScale > 1.30
                    ? 1
                    : constraints.maxWidth >= 760
                        ? 3
                        : constraints.maxWidth >= 440
                            ? 2
                            : 1;

                if (columns == 1) {
                  return Column(
                    children: [
                      for (var i = 0; i < others.length; i++) ...[
                        _EmergencyTile(
                          service: others[i],
                          icon: _icon(others[i]),
                          callService: caller,
                          compact: true,
                        ),
                        if (i != others.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: others.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 156,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, i) => _EmergencyTile(
                    service: others[i],
                    icon: _icon(others[i]),
                    callService: caller,
                    compact: false,
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ), const SizedBox(width: 8), Text(t.get('official_sources'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]),
            const SizedBox(height: 5),
            if (country.sources.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  en
                      ? 'No country-specific official source is bundled yet.'
                      : 'Aucune source officielle spécifique au pays n’est encore intégrée.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              ...country.sources.map(
                (source) => ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    source.host,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 17,
                  ),
                  onTap: () async {
                    final opened = await launchUrl(
                      source,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            en
                                ? 'Unable to open this official source.'
                                : 'Impossible d’ouvrir cette source officielle.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            Text(
              country.verifiedOn != null
                  ? t.get(
                      'verified_on',
                      {
                        'date': country.verifiedOn!
                            .toIso8601String()
                            .substring(0, 10),
                      },
                    )
                  : t.get('numbers_unverified'),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ]))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerHero extends StatelessWidget {
  const _DangerHero({required this.service, required this.callService});
  final EmergencyService service;
  final EmergencyCallService callService;
  @override Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.error.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: scheme.error, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.phone_in_talk, color: scheme.onError, size: 27)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(en ? 'IMMEDIATE DANGER' : 'DANGER IMMÉDIAT', style: TextStyle(fontSize: 12, letterSpacing: .4, fontWeight: FontWeight.w900, color: scheme.onErrorContainer)), Text(en ? 'Call ${service.number ?? ''}' : 'Appelez le ${service.number ?? ''}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text(t.get(service.nameKey), style: TextStyle(fontSize: 13, color: scheme.onErrorContainer))]))]),
      const SizedBox(height: 13),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: scheme.error, minimumSize: const Size.fromHeight(48)), onPressed: () => _call(context, t, service, callService), icon: const Icon(Icons.call), label: Text(en ? 'Call ${service.number ?? ''}' : 'Appeler ${service.number ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)))),
        ],
      ),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  const _EmergencyTile({
    required this.service,
    required this.icon,
    required this.callService,
    required this.compact,
  });

  final EmergencyService service;
  final IconData icon;
  final EmergencyCallService callService;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isRega = service.id == 'rega';
    final scheme = Theme.of(context).colorScheme;
    final accent = isRega ? scheme.secondary : scheme.error;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _call(
          context,
          t,
          service,
          callService,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: compact
              ? Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isRega
                            ? scheme.secondaryContainer
                            : scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: accent,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.number ?? '—',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                          ),
                          Text(
                            t.get(service.nameKey),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.call_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isRega
                                ? scheme.secondaryContainer
                                : scheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: accent,
                            size: 23,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.call_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      service.number ?? '—',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    Text(
                      t.get(service.nameKey),
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _UnverifiedCountryNotice extends StatelessWidget {
  const _UnverifiedCountryNotice({
    required this.en,
    required this.countryName,
  });

  final bool en;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.tertiary.withValues(alpha: .35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'ReadySafe does not yet have a verified callable emergency number for $countryName.'
                        : 'ReadySafe ne dispose pas encore d’un numéro d’urgence appelable vérifié pour $countryName.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              en
                  ? 'Do not rely on an unverified number. Use the phone’s native emergency features and verify local official information.'
                  : 'Ne vous fiez pas à un numéro non vérifié. Utilisez les fonctions d’urgence natives du téléphone et vérifiez les informations officielles locales.',
              style: const TextStyle(height: 1.35),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OfficialSourcesScreen(),
                ),
              ),
              icon: const Icon(Icons.verified_user_outlined),
              label: Text(
                en ? 'Official sources' : 'Sources officielles',
              ),
            ),
          ],
        ),
      );
  }
}

Future<void> _call(BuildContext context, AppLocalizations t, EmergencyService service, EmergencyCallService caller) async {
  final number=service.number; if(number==null||!service.isCallable)return;
  final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(icon:Icon(Icons.phone_in_talk,color:Theme.of(context).colorScheme.error,size:34),title:Text(t.get('call_confirm_title')),content:Text(t.get('call_confirm_body',{'number':number,'service':t.get(service.nameKey)})),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:Text(t.get('cancel'))),FilledButton(style:FilledButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.error),onPressed:()=>Navigator.pop(c,true),child:Text(t.get('call')))]))??false;
  if(!ok||!context.mounted)return; final launched=await caller.call(number); if(!launched&&context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t.get('call_failed'))));
}
