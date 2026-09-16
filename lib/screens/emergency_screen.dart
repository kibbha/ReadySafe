import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../models/country_profile.dart';
import '../services/emergency_call_service.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, this.callService});
  final EmergencyCallService? callService;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context),
        country = AppScope.of(context).activeCountry!;
    return Scaffold(
      appBar: AppBar(title: Text(t.get('emergencies'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${t.get(country.nameKey)} · ${country.isoCode}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(t.get('emergency_hint')),
          const SizedBox(height: 16),
          ...country.services.map(
            (service) => _EmergencyButton(
              service: service,
              callService: callService ?? DeviceEmergencyCallService(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.get('country_information'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          ...country.informationKeys.map(
            (key) => ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(t.get(key)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.get('official_sources'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          ...country.sources.map(
            (source) => ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(source.host),
              subtitle: Text(source.toString()),
              onTap: () =>
                  launchUrl(source, mode: LaunchMode.externalApplication),
            ),
          ),
          Text(
            t.get('verified_on', {
              'date': country.verifiedOn.toIso8601String().substring(0, 10),
            }),
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.service, required this.callService});
  final EmergencyService service;
  final EmergencyCallService callService;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: '${t.get('call')} ${t.get(service.nameKey)} ${service.number}',
        child: FilledButton.tonal(
          onPressed: () => _confirm(context, t),
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
          child: Row(
            children: [
              const Icon(Icons.phone_in_talk, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(service.nameKey),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(t.get(service.descriptionKey)),
                  ],
                ),
              ),
              Text(
                service.number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, AppLocalizations t) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.get('call_confirm_title')),
            content: Text(
              t.get('call_confirm_body', {
                'number': service.number,
                'service': t.get(service.nameKey),
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t.get('cancel')),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.phone),
                label: Text(t.get('call')),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    final launched = await callService.call(service.number);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.get('call_failed'))));
    }
  }
}
