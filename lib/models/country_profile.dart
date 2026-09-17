enum DataVerification { verified, needsVerification }

class EmergencyService {
  const EmergencyService({
    required this.id,
    required this.nameKey,
    required this.number,
    required this.descriptionKey,
    this.verification = DataVerification.verified,
    this.source,
  });

  final String id;
  final String nameKey;
  final String? number;
  final String descriptionKey;
  final DataVerification verification;
  final Uri? source;

  bool get isCallable =>
      number != null && verification == DataVerification.verified;
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
    this.region = 'Europe',
  });

  final String isoCode;
  final String nameKey;
  final List<String> languages;
  final List<EmergencyService> services;
  final List<String> informationKeys;
  final List<Uri> sources;
  final DateTime? verifiedOn;
  final String region;

  bool get hasVerifiedNumbers => services.any((service) => service.isCallable);
}
