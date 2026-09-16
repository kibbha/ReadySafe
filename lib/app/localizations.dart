import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  static const _fr = {
    'title': 'READYSAFE',
    'subtitle': 'Préparez-vous. Restez en sécurité.',
    'emergencies': 'Urgences',
    'firstAid': 'Premiers secours',
    'disasters': 'Catastrophes',
    'kit': 'Kit d’urgence',
    'checklists': 'Check-lists',
    'waterFood': 'Eau & nourriture',
    'family': 'Famille',
    'contacts': 'Contacts d’urgence',
    'maps': 'Cartes hors-ligne',
    'information': 'Informations',
    'medicalNotice':
        'Informations générales : elles ne remplacent pas les secours ni un professionnel de santé.',
    'save': 'Enregistrer',
    'adults': 'Adultes',
    'children': 'Enfants',
    'days': 'Jours',
    'waterResult': 'Eau recommandée',
    'foodResult': 'Repas recommandés',
    'offline': 'Disponible hors connexion',
  };
  static const _en = {
    'title': 'READYSAFE',
    'subtitle': 'Be prepared. Stay safe.',
    'emergencies': 'Emergencies',
    'firstAid': 'First aid',
    'disasters': 'Disasters',
    'kit': 'Emergency kit',
    'checklists': 'Checklists',
    'waterFood': 'Water & food',
    'family': 'Family',
    'contacts': 'Emergency contacts',
    'maps': 'Offline maps',
    'information': 'Information',
    'medicalNotice':
        'General information only: it does not replace emergency services or healthcare professionals.',
    'save': 'Save',
    'adults': 'Adults',
    'children': 'Children',
    'days': 'Days',
    'waterResult': 'Recommended water',
    'foodResult': 'Recommended meals',
    'offline': 'Available offline',
  };
  String get(String key) =>
      (locale.languageCode == 'en' ? _en : _fr)[key] ?? key;
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static const delegate = _Delegate();
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale l) => ['fr', 'en'].contains(l.languageCode);
  @override
  Future<AppLocalizations> load(Locale l) async => AppLocalizations(l);
  @override
  bool shouldReload(_Delegate old) => false;
}
