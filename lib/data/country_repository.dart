import '../models/country_profile.dart';

/// Maintained registry of verified country data. Every entry must include
/// authoritative source URLs and a review date before being enabled.
class CountryRepository {
  static final List<CountryProfile> supported = [
    CountryProfile(
      isoCode: 'FR',
      nameKey: 'country_france',
      languages: const ['fr'],
      services: const [
        EmergencyService(
          id: 'eu',
          nameKey: 'service_emergency',
          number: '112',
          descriptionKey: 'service_112_desc',
        ),
        EmergencyService(
          id: 'medical',
          nameKey: 'service_ambulance',
          number: '15',
          descriptionKey: 'service_samu_desc',
        ),
        EmergencyService(
          id: 'police',
          nameKey: 'service_police',
          number: '17',
          descriptionKey: 'service_police_desc',
        ),
        EmergencyService(
          id: 'fire',
          nameKey: 'service_fire',
          number: '18',
          descriptionKey: 'service_fire_desc',
        ),
        EmergencyService(
          id: 'accessible',
          nameKey: 'service_accessible',
          number: '114',
          descriptionKey: 'service_114_desc',
        ),
      ],
      informationKeys: const ['info_fr_alert', 'info_eu_112'],
      sources: [
        Uri.parse(
          'https://www.service-public.fr/particuliers/actualites/A15841',
        ),
      ],
      verifiedOn: DateTime.utc(2026, 9, 16),
    ),
    CountryProfile(
      isoCode: 'BE',
      nameKey: 'country_belgium',
      languages: const ['fr', 'nl', 'de'],
      services: const [
        EmergencyService(
          id: 'eu',
          nameKey: 'service_emergency',
          number: '112',
          descriptionKey: 'service_be_112_desc',
        ),
        EmergencyService(
          id: 'police',
          nameKey: 'service_police',
          number: '101',
          descriptionKey: 'service_be_police_desc',
        ),
      ],
      informationKeys: const ['info_be_112', 'info_eu_112'],
      sources: [Uri.parse('https://112.be/fr')],
      verifiedOn: DateTime.utc(2026, 9, 16),
    ),
    CountryProfile(
      isoCode: 'DE',
      nameKey: 'country_germany',
      languages: const ['de'],
      services: const [
        EmergencyService(
          id: 'eu',
          nameKey: 'service_emergency',
          number: '112',
          descriptionKey: 'service_de_112_desc',
        ),
        EmergencyService(
          id: 'police',
          nameKey: 'service_police',
          number: '110',
          descriptionKey: 'service_de_police_desc',
        ),
      ],
      informationKeys: const ['info_de_warning', 'info_eu_112'],
      sources: [
        Uri.parse(
          'https://www.bbk.bund.de/EN/Prepare-for-disasters/Personal-Preparedness/Emergency-call/emergency-call_node.html',
        ),
      ],
      verifiedOn: DateTime.utc(2026, 9, 16),
    ),
    CountryProfile(
      isoCode: 'IT',
      nameKey: 'country_italy',
      languages: const ['it'],
      services: const [
        EmergencyService(
          id: 'eu',
          nameKey: 'service_emergency',
          number: '112',
          descriptionKey: 'service_it_112_desc',
        ),
      ],
      informationKeys: const ['info_it_112', 'info_eu_112'],
      sources: [
        Uri.parse(
          'https://www.interno.gov.it/it/temi/sicurezza/numero-unico-emergenza-112',
        ),
      ],
      verifiedOn: DateTime.utc(2026, 9, 16),
    ),
  ];

  static CountryProfile? byCode(String? code) {
    for (final country in supported) {
      if (country.isoCode == code) return country;
    }
    return null;
  }
}
