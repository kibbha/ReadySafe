class EmergencyService {
  const EmergencyService({
    required this.id,
    required this.nameKey,
    required this.number,
    required this.descriptionKey,
  });

  final String id;
  final String nameKey;
  final String number;
  final String descriptionKey;
}

class CountryProfile {
  const CountryProfile({
    required this.isoCode,
    required this.nameKey,
    required this.languages,
    required this.services,
    required this.informationKeys,
    required this.sources,
    required this.verifiedOn,
  });

  final String isoCode;
  final String nameKey;
  final List<String> languages;
  final List<EmergencyService> services;
  final List<String> informationKeys;
  final List<Uri> sources;
  final DateTime verifiedOn;
}
