import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../data/content.dart';
import '../data/country_repository.dart';
import '../data/first_aid_repository.dart';
import '../services/local_storage_service.dart';
import '../services/secure_vault_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final _storage = LocalStorageService();
  final _vault = SecureVaultService();

  bool _running = true;
  List<_DiagnosticResult> _results = [];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    if (mounted) {
      setState(() {
        _running = true;
        _results = [];
      });
    }

    final results = <_DiagnosticResult>[];

    final countriesWithoutNumber = CountryRepository.supported.where((country) {
      return !country.services.any(
        (service) => service.isCallable && (service.number ?? '').trim().isNotEmpty,
      );
    }).toList();

    results.add(
      _DiagnosticResult(
        'Emergency numbers',
        countriesWithoutNumber.isEmpty,
        countriesWithoutNumber.isEmpty
            ? '${CountryRepository.supported.length} supported countries have at least one callable emergency number.'
            : '${countriesWithoutNumber.length} country profile(s) have no callable emergency number.',
      ),
    );

    final invalidGuides = firstAidGuides.where(
      (guide) => guide.steps.isEmpty || guide.sourceUris.isEmpty,
    ).toList();
    results.add(
      _DiagnosticResult(
        'First-aid data',
        invalidGuides.isEmpty,
        invalidGuides.isEmpty
            ? '${firstAidGuides.length} first-aid guides have steps and reference sources.'
            : '${invalidGuides.length} guide(s) are incomplete.',
      ),
    );

    var assetCount = 0;
    final missingAssets = <String>[];
    final uniqueAssets = <String>{
      for (final guide in firstAidGuides)
        for (final step in guide.steps) step.illustrationAsset,
    };

    for (final asset in uniqueAssets) {
      try {
        await rootBundle.load(asset);
        assetCount++;
      } catch (_) {
        missingAssets.add(asset);
      }
    }

    results.add(
      _DiagnosticResult(
        'Illustrated first aid',
        missingAssets.isEmpty,
        missingAssets.isEmpty
            ? '$assetCount SVG illustration asset(s) resolved successfully.'
            : '${missingAssets.length} illustration asset(s) are missing.',
        details: missingAssets,
      ),
    );

    try {
      final family = await _storage.family();
      final docs = await _storage.emergencyDocuments();
      final markers = await _storage.safetyMarkers();
      final stock = await _storage.kitStock();
      final contacts = await _storage.familyContacts();
      final recovery = await _storage.recoveryLog();

      final people = (family['adults'] ?? 0) +
          (family['children'] ?? 0) +
          (family['care'] ?? 0);

      results.add(
        _DiagnosticResult(
          'Local offline storage',
          true,
          '$people household member(s) · ${contacts.length} contact(s) · '
          '${docs.length} document category(ies) · ${stock.length} stock entry(ies) · '
          '${markers.length} personal marker(s).',
        ),
      );

      results.add(
        _DiagnosticResult(
          'Recovery log storage',
          true,
          recovery.values.any((value) => value.trim().isNotEmpty)
              ? 'A recovery log exists locally.'
              : 'Recovery log storage is readable and currently empty.',
        ),
      );
    } catch (error) {
      results.add(
        _DiagnosticResult(
          'Local offline storage',
          false,
          'Local storage read failed: $error',
        ),
      );
    }

    try {
      final count = await _vault.count();
      results.add(
        _DiagnosticResult(
          'Secure vault',
          true,
          'Secure-vault service responded · $count encrypted entrie(s) currently stored.',
        ),
      );
    } catch (error) {
      results.add(
        _DiagnosticResult(
          'Secure vault',
          false,
          'Secure-vault service failed: $error',
        ),
      );
    }

    results.add(
      _DiagnosticResult(
        'Offline survival content',
        emergencyGuides.isNotEmpty && disasterGuides.isNotEmpty,
        '${emergencyGuides.length} emergency resource guide(s) · '
        '${disasterGuides.length} disaster guide(s) bundled.',
      ),
    );

    if (!mounted) return;
    setState(() {
      _results = results;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final app = AppScope.of(context);
    final passed = _results.where((result) => result.ok).length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'ReadySafe diagnostics' : 'Diagnostic ReadySafe'),
        actions: [
          IconButton(
            tooltip: en ? 'Run again' : 'Relancer',
            onPressed: _running ? null : _run,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _running
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: passed == _results.length
                            ? const Color(0xff087f83)
                            : const Color(0xffd92d36),
                        child: Icon(
                          passed == _results.length
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              passed == _results.length
                                  ? (en ? 'Core self-check passed' : 'Auto-contrôle principal réussi')
                                  : (en ? 'Some checks need attention' : 'Certains contrôles demandent une vérification'),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              en
                                  ? '$passed / ${_results.length} checks passed · active country: ${app.activeCountry?.isoCode ?? '—'} · language: ${app.settings.localeCode.toUpperCase()}'
                                  : '$passed / ${_results.length} contrôles réussis · pays actif : ${app.activeCountry?.isoCode ?? '—'} · langue : ${app.settings.localeCode.toUpperCase()}',
                              style: const TextStyle(
                                color: Color(0xff65747a),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final result in _results)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: result.ok
                            ? const Color(0xffdff2ed)
                            : const Color(0xffffe5e7),
                        child: Icon(
                          result.ok
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: result.ok
                              ? const Color(0xff087f83)
                              : const Color(0xffd92d36),
                        ),
                      ),
                      title: Text(
                        result.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(result.summary),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        if (result.details.isNotEmpty)
                          for (final detail in result.details)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '• $detail',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              en
                                  ? 'No additional error detail.'
                                  : 'Aucun détail d’erreur supplémentaire.',
                              style: const TextStyle(color: Color(0xff65747a)),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.build_outlined, color: Color(0xff9a6a00)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'This diagnostic checks bundled data, assets and local services. It does not replace the final Android analyse/test/build validation.'
                              : 'Ce diagnostic vérifie les données embarquées, illustrations et services locaux. Il ne remplace pas la validation finale Analyze/Test/Build Android.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DiagnosticResult {
  const _DiagnosticResult(
    this.title,
    this.ok,
    this.summary, {
    this.details = const [],
  });

  final String title;
  final bool ok;
  final String summary;
  final List<String> details;
}
