import '../models/country_profile.dart';

/// Central European country registry.
/// Only verified numbers are exposed as callable actions.
class CountryRepository {
  static final Uri _eu112 = Uri.parse('https://digital-strategy.ec.europa.eu/en/policies/112');
  static final Uri _uk999 = Uri.parse('https://www.gov.uk/guidance/999-and-112-the-uks-national-emergency-numbers');
  static final Uri _chOfcom = Uri.parse('https://www.bakom.admin.ch/en/other-numbers-free-of-charge-or-not');
  static final Uri _chRega = Uri.parse('https://www.rega.ch/en/emergency-number-1414');

  static const Set<String> _euMemberStates = {
    'AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IE','IT','LV','LT','LU','MT','NL','PL','PT','RO','SK','SI','ES','SE',
  };

  static final List<CountryProfile> supported = _seeds.map(_build).toList()..sort((a,b)=>a.nameKey.compareTo(b.nameKey));

  static CountryProfile _build(_CountrySeed seed) {
    final detailed = _verifiedServices[seed.code];
    final eu112Only = detailed == null && _euMemberStates.contains(seed.code);
    final services = detailed ?? (eu112Only
      ? [_service('eu','service_emergency','112','service_112_desc')]
      : [const EmergencyService(id:'general',nameKey:'service_emergency',number:null,descriptionKey:'service_unverified_desc',verification:DataVerification.needsVerification)]);
    return CountryProfile(
      isoCode: seed.code, nameKey: seed.nameKey, languages: seed.languages, services: services,
      informationKeys: detailed != null || eu112Only ? const ['info_eu_112'] : const ['info_numbers_pending'],
      sources: _sources[seed.code] ?? (eu112Only ? [_eu112] : const []),
      verifiedOn: detailed != null || eu112Only ? DateTime.utc(2026,9,17) : null,
    );
  }

  static CountryProfile? byCode(String? code) { for (final c in supported) { if (c.isoCode==code) return c; } return null; }
  static List<CountryProfile> search(String query) { final q=query.trim().toLowerCase(); if(q.isEmpty)return List.unmodifiable(supported); return supported.where((c)=>c.isoCode.toLowerCase().contains(q)||c.nameKey.toLowerCase().contains(q)).toList(); }

  static final Map<String,List<Uri>> _sources = {
    'FR':[Uri.parse('https://www.service-public.fr/particuliers/actualites/A15841'),_eu112],
    'BE':[Uri.parse('https://112.be/fr'),_eu112],
    'DE':[Uri.parse('https://www.bbk.bund.de/EN/Prepare-for-disasters/Personal-Preparedness/Emergency-call/emergency-call_node.html'),_eu112],
    'IT':[Uri.parse('https://www.interno.gov.it/it/temi/sicurezza/numero-unico-emergenza-112'),_eu112],
    'GB':[_uk999],
    'CH':[_chOfcom,_chRega,_eu112],
    'NO':[
      Uri.parse('https://www.dsb.no/brannsikkerhet/nodmelding/110-sentralene/'),
      Uri.parse('https://www.politiet.no/en/english'),
      Uri.parse('https://www.helsenorge.no/en/healthcare'),
    ],
    'IS':[Uri.parse('https://www.112.is/en/112')],
    'TR':[Uri.parse('https://www.112.gov.tr/')],
    'LI':[Uri.parse('https://www.llv.li/de/landesverwaltung/amt-fuer-bevoelkerungsschutz/rettungs--hilfsorganisationen/notrufnummern')],
    'GE':[Uri.parse('https://112.gov.ge/?lang=en&page_id=1686')],
    'MD':[Uri.parse('https://www.gov.md/index.php/en/useful-information')],
    'AL':[Uri.parse('https://akmc.gov.al/en/home/')],
    'MK':[Uri.parse('https://cuk.gov.mk/Page/Contact')],
  };

  static final Map<String,List<EmergencyService>> _verifiedServices = {
    'FR':[_service('eu','service_emergency','112','service_112_desc'),_service('medical','service_ambulance','15','service_samu_desc'),_service('police','service_police','17','service_police_desc'),_service('fire','service_fire','18','service_fire_desc'),_service('accessible','service_accessible','114','service_114_desc')],
    'BE':[_service('eu','service_emergency','112','service_be_112_desc'),_service('police','service_police','101','service_be_police_desc')],
    'DE':[_service('eu','service_emergency','112','service_de_112_desc'),_service('police','service_police','110','service_de_police_desc')],
    'IT':[_service('eu','service_emergency','112','service_it_112_desc')],
    'GB':[_service('general','service_emergency','999','service_112_desc'),_service('eu','service_emergency','112','service_112_desc')],
    'NO':[
      _service('fire','service_fire','110','service_no_fire_desc'),
      _service('police','service_police','112','service_no_police_desc'),
      _service('medical','service_ambulance','113','service_no_ambulance_desc'),
    ],
    'IS':[
      _service('general','service_emergency','112','service_is_112_desc'),
    ],
    'TR':[
      _service('general','service_emergency','112','service_tr_112_desc'),
    ],
    'LI':[
      _service('eu','service_emergency','112','service_li_112_desc'),
      _service('police','service_police','117','service_li_police_desc'),
      _service('fire','service_fire','118','service_li_fire_desc'),
      _service('medical','service_ambulance','144','service_li_ambulance_desc'),
    ],
    'GE':[
      _service('general','service_emergency','112','service_ge_112_desc'),
    ],
    'MD':[
      _service('general','service_emergency','112','service_md_112_desc'),
    ],
    'AL':[
      _service('general','service_emergency','112','service_al_112_desc'),
    ],
    'MK':[
      _service('general','service_emergency','112','service_mk_112_desc'),
    ],
    'CH':[
      _service('eu','service_emergency','112','service_112_desc'),
      _service('medical','service_ambulance','144','service_ch_ambulance_desc'),
      _service('police','service_police','117','service_police_desc'),
      _service('fire','service_fire','118','service_fire_desc'),
      _service('rega','service_rega','1414','service_rega_desc'),
      _service('poison','service_poison','145','service_poison_desc'),
      _service('adult_help','service_adult_help','143','service_adult_help_desc'),
      _service('youth_help','service_youth_help','147','service_youth_help_desc'),
    ],
  };

  static EmergencyService _service(String id,String nameKey,String number,String descriptionKey)=>EmergencyService(id:id,nameKey:nameKey,number:number,descriptionKey:descriptionKey);

  static const List<_CountrySeed> _seeds=[
    _CountrySeed('AL','country_albania',['sq']),_CountrySeed('DE','country_germany',['de']),_CountrySeed('AD','country_andorra',['ca']),_CountrySeed('AM','country_armenia',['hy']),_CountrySeed('AT','country_austria',['de']),_CountrySeed('AZ','country_azerbaijan',['az']),_CountrySeed('BE','country_belgium',['fr','nl','de']),_CountrySeed('BY','country_belarus',['be','ru']),_CountrySeed('BA','country_bosnia',['bs','hr','sr']),_CountrySeed('BG','country_bulgaria',['bg']),_CountrySeed('CY','country_cyprus',['el','tr']),_CountrySeed('HR','country_croatia',['hr']),_CountrySeed('DK','country_denmark',['da']),_CountrySeed('ES','country_spain',['es']),_CountrySeed('EE','country_estonia',['et']),_CountrySeed('FI','country_finland',['fi','sv']),_CountrySeed('FR','country_france',['fr']),_CountrySeed('GE','country_georgia',['ka']),_CountrySeed('GR','country_greece',['el']),_CountrySeed('HU','country_hungary',['hu']),_CountrySeed('IE','country_ireland',['en','ga']),_CountrySeed('IS','country_iceland',['is']),_CountrySeed('IT','country_italy',['it']),_CountrySeed('XK','country_kosovo',['sq','sr']),_CountrySeed('LV','country_latvia',['lv']),_CountrySeed('LI','country_liechtenstein',['de']),_CountrySeed('LT','country_lithuania',['lt']),_CountrySeed('LU','country_luxembourg',['lb','fr','de']),_CountrySeed('MK','country_north_macedonia',['mk','sq']),_CountrySeed('MT','country_malta',['mt','en']),_CountrySeed('MD','country_moldova',['ro']),_CountrySeed('MC','country_monaco',['fr']),_CountrySeed('ME','country_montenegro',['cnr']),_CountrySeed('NO','country_norway',['no']),_CountrySeed('NL','country_netherlands',['nl']),_CountrySeed('PL','country_poland',['pl']),_CountrySeed('PT','country_portugal',['pt']),_CountrySeed('CZ','country_czechia',['cs']),_CountrySeed('RO','country_romania',['ro']),_CountrySeed('GB','country_united_kingdom',['en']),_CountrySeed('SM','country_san_marino',['it']),_CountrySeed('RS','country_serbia',['sr']),_CountrySeed('SK','country_slovakia',['sk']),_CountrySeed('SI','country_slovenia',['sl']),_CountrySeed('SE','country_sweden',['sv']),_CountrySeed('CH','country_switzerland',['de','fr','it','rm']),_CountrySeed('TR','country_turkiye',['tr']),_CountrySeed('UA','country_ukraine',['uk']),_CountrySeed('VA','country_vatican',['it','la']),
  ];
}
class _CountrySeed { const _CountrySeed(this.code,this.nameKey,this.languages); final String code; final String nameKey; final List<String> languages; }
