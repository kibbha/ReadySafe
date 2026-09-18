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

    final countriesWithoutNumber = CountryRepository.supported.where(
      (country) => !country.services.any(
        (service) =>
            service.isCallable &&
            (service.number ?? '').trim().isNotEmpty,
      ),
    ).toList();

    results.add(
      _DiagnosticResult(
        id: 'emergency_numbers',
        ok: countriesWithoutNumber.isEmpty,
        values: {
          'supported': CountryRepository.supported.length,
          'missing': countriesWithoutNumber.length,
        },
      ),
    );

    final invalidGuides = firstAidGuides.where(
      (guide) => guide.steps.isEmpty || guide.sourceUris.isEmpty,
    ).toList();

    results.add(
      _DiagnosticResult(
        id: 'first_aid_data',
        ok: invalidGuides.isEmpty,
        values: {
          'count': firstAidGuides.length,
          'invalid': invalidGuides.length,
        },
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
        id: 'illustrations',
        ok: missingAssets.isEmpty,
        values: {
          'count': assetCount,
          'missing': missingAssets.length,
        },
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
          id: 'local_storage',
          ok: true,
          values: {
            'people': people,
            'contacts': contacts.length,
            'docs': docs.length,
            'stock': stock.length,
            'markers': markers.length,
          },
        ),
      );

      results.add(
        _DiagnosticResult(
          id: 'recovery_storage',
          ok: true,
          values: {
            'hasData': recovery.values.any(
              (value) => value.trim().isNotEmpty,
            ),
          },
        ),
      );
    } catch (error) {
      results.add(
        _DiagnosticResult(
          id: 'local_storage',
          ok: false,
          values: {'error': '$error'},
        ),
      );
    }

    try {
      final count = await _vault.count();
      results.add(
        _DiagnosticResult(
          id: 'secure_vault',
          ok: true,
          values: {'count': count},
        ),
      );
    } catch (error) {
      results.add(
        _DiagnosticResult(
          id: 'secure_vault',
          ok: false,
          values: {'error': '$error'},
        ),
      );
    }

    results.add(
      _DiagnosticResult(
        id: 'offline_content',
        ok: emergencyGuides.isNotEmpty && disasterGuides.isNotEmpty,
        values: {
          'emergency': emergencyGuides.length,
          'disaster': disasterGuides.length,
        },
      ),
    );

    if (!mounted) return;

    setState(() {
      _results = results;
      _running = false;
    });
  }

  String _title(_DiagnosticResult result, bool en) {
    const enTitles = {
      'emergency_numbers': 'Emergency numbers',
      'first_aid_data': 'First-aid data',
      'illustrations': 'Illustrated first aid',
      'local_storage': 'Local offline storage',
      'recovery_storage': 'Recovery log storage',
      'secure_vault': 'Secure vault',
      'offline_content': 'Offline survival content',
    };

    const frTitles = {
      'emergency_numbers': 'Numéros d’urgence',
      'first_aid_data': 'Données premiers secours',
      'illustrations': 'Premiers secours illustrés',
      'local_storage': 'Stockage local hors ligne',
      'recovery_storage': 'Journal après urgence',
      'secure_vault': 'Coffre sécurisé',
      'offline_content': 'Contenu de survie hors ligne',
    };

    return (en ? enTitles : frTitles)[result.id] ?? result.id;
  }

  String _summary(_DiagnosticResult result, bool en) {
    final v = result.values;

    switch (result.id) {
      case 'emergency_numbers':
        return result.ok
            ? (en
                ? '${v['supported']} supported country profiles have at least one callable emergency number.'
                : '${v['supported']} profils pays disposent d’au moins un numéro d’urgence appelable.')
            : (en
                ? '${v['missing']} country profile(s) have no callable emergency number.'
                : '${v['missing']} profil(s) pays ne disposent d’aucun numéro d’urgence appelable.');
      case 'first_aid_data':
        return result.ok
            ? (en
                ? '${v['count']} first-aid guides include steps and reference sources.'
                : '${v['count']} fiches de premiers secours contiennent des étapes et des sources de référence.')
            : (en
                ? '${v['invalid']} first-aid guide(s) are incomplete.'
                : '${v['invalid']} fiche(s) de premiers secours sont incomplètes.');
      case 'illustrations':
        return result.ok
            ? (en
                ? '${v['count']} SVG illustration asset(s) resolved successfully.'
                : '${v['count']} illustration(s) SVG ont été chargées correctement.')
            : (en
                ? '${v['missing']} illustration asset(s) are missing.'
                : '${v['missing']} illustration(s) sont manquantes.');
      case 'local_storage':
        if (!result.ok) {
          return en
              ? 'Local storage read failed: ${v['error']}'
              : 'Échec de lecture du stockage local : ${v['error']}';
        }
        return en
            ? '${v['people']} household member(s) · ${v['contacts']} contact(s) · ${v['docs']} document category(ies) · ${v['stock']} stock entry(ies) · ${v['markers']} personal landmark(s).'
            : '${v['people']} personne(s) dans le foyer · ${v['contacts']} contact(s) · ${v['docs']} catégorie(s) de documents · ${v['stock']} entrée(s) de stock · ${v['markers']} repère(s) personnel(s).';
      case 'recovery_storage':
        return v['hasData'] == true
            ? (en
                ? 'A recovery log exists locally.'
                : 'Un journal après urgence est enregistré localement.')
            : (en
                ? 'Recovery-log storage is readable and currently empty.'
                : 'Le stockage du journal après urgence est lisible et actuellement vide.');
      case 'secure_vault':
        return result.ok
            ? (en
                ? 'Secure-storage service responded · ${v['count']} encrypted entrie(s) currently stored.'
                : 'Le stockage sécurisé répond correctement · ${v['count']} entrée(s) chiffrée(s) actuellement enregistrée(s).')
            : (en
                ? 'Secure-storage service failed: ${v['error']}'
                : 'Échec du stockage sécurisé : ${v['error']}');
      case 'offline_content':
        return en
            ? '${v['emergency']} emergency resource guide(s) · ${v['disaster']} disaster guide(s) bundled.'
            : '${v['emergency']} guide(s) de réflexes d’urgence · ${v['disaster']} guide(s) risques et catastrophes embarqués.';
      default:
        return result.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final app = AppScope.of(context);
    final passed = _results.where((result) => result.ok).length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(
          en ? 'ReadySafe diagnostics' : 'Diagnostic ReadySafe',
        ),
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
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffe4f3f0),
                            Color(0xfffff4e8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                passed == _results.length
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  passed == _results.length
                                      ? (en
                                          ? 'Core self-check passed'
                                          : 'Auto-contrôle principal réussi')
                                      : (en
                                          ? 'Some checks need attention'
                                          : 'Certains contrôles demandent une vérification'),
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
                        margin:
                            const EdgeInsets.only(bottom: 8),
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
                            _title(result, en),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            _summary(result, en),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            12,
                          ),
                          children: [
                            if (result.details.isNotEmpty)
                              for (final detail
                                  in result.details)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Align(
                                    alignment:
                                        Alignment.centerLeft,
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
                                  style: const TextStyle(
                                    color: Color(0xff65747a),
                                  ),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.build_outlined,
                            color: Color(0xff9a6a00),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              en
                                  ? 'This diagnostic checks bundled data, assets and local services. It does not replace the final Android Analyze/Test/Build validation.'
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
              ),
            ),
    );
  }
}

class _DiagnosticResult {
  const _DiagnosticResult({
    required this.id,
    required this.ok,
    this.values = const {},
    this.details = const [],
  });

  final String id;
  final bool ok;
  final Map<String, Object?> values;
  final List<String> details;
}
