import '../models/first_aid_guide.dart';

// Guidance is stored offline and versioned against authoritative references.
// Illustrations are original ReadySafe assets; third-party medical artwork is
// deliberately not bundled.
final _erc2025 = Uri.parse(
  'https://www.erc.edu/science-research/guidelines/guidelines-2025/',
);
final _ercAdultBls2025 = Uri.parse(
  'https://www.erc.edu/media/wrhj5sye/gl2025-04-bls-e.pdf',
);
final _ercPaediatric2025 = Uri.parse(
  'https://www.erc.edu/media/03xnpjmj/gl2025-09-pls-e.pdf',
);
final _ercFirstAid2025 = Uri.parse(
  'https://www.erc.edu/media/i2vllpae/gl2025-12-faid-e.pdf',
);
final _nhsFirstAid = Uri.parse('https://www.nhs.uk/conditions/first-aid/');

FirstAidGuide _guide(
  String id,
  String title,
  String summary,
  List<String> steps, {
  List<Uri>? sources,
  List<String>? illustrations,
}) => FirstAidGuide(
  id: id,
  titleKey: title,
  summaryKey: summary,
  steps: [
    for (var i = 0; i < steps.length; i++)
      FirstAidStep(
        textKey: steps[i],
        illustrationAsset: illustrations != null && i < illustrations.length
            ? illustrations[i]
            : switch (i % 3) {
                0 => 'assets/illustrations/assess.svg',
                1 => 'assets/illustrations/call.svg',
                _ => 'assets/illustrations/care.svg',
              },
      ),
  ],
  sourceUris: sources ?? [_erc2025, _ercFirstAid2025, _nhsFirstAid],
);

final firstAidGuides = [
  _guide(
    'cpr_adult',
    'aid_cpr_adult',
    'aid_cpr_summary',
    ['aid_cpr_1', 'aid_cpr_2', 'aid_cpr_3', 'aid_cpr_4'],
    sources: [_erc2025, _ercAdultBls2025],
    illustrations: [
      'assets/illustrations/cpr_adult_1.svg',
      'assets/illustrations/cpr_adult_2.svg',
      'assets/illustrations/cpr_adult_3.svg',
      'assets/illustrations/cpr_adult_4.svg',
    ],
  ),
  _guide('aed', 'aid_aed', 'aid_aed_summary', ['aid_aed_1', 'aid_aed_2', 'aid_aed_3']),
  _guide(
    'cpr_child',
    'aid_cpr_child',
    'aid_cpr_child_summary',
    ['aid_child_cpr_1', 'aid_child_cpr_2', 'aid_child_cpr_3', 'aid_child_cpr_4'],
    sources: [_erc2025, _ercPaediatric2025],
    illustrations: [
      'assets/illustrations/cpr_child_assess.svg',
      'assets/illustrations/cpr_child_breaths.svg',
      'assets/illustrations/cpr_child_compressions.svg',
      'assets/illustrations/cpr_child_aed.svg',
    ],
  ),
  _guide(
    'cpr_infant',
    'aid_cpr_infant',
    'aid_cpr_infant_summary',
    ['aid_infant_cpr_1', 'aid_infant_cpr_2', 'aid_infant_cpr_3', 'aid_infant_cpr_4'],
    sources: [_erc2025, _ercPaediatric2025],
    illustrations: [
      'assets/illustrations/cpr_infant_assess.svg',
      'assets/illustrations/cpr_infant_breaths.svg',
      'assets/illustrations/cpr_infant_compressions.svg',
      'assets/illustrations/cpr_infant_aed.svg',
    ],
  ),
  _guide(
    'choking_adult',
    'aid_choking_adult',
    'aid_choking_summary',
    ['aid_choking_1', 'aid_choking_2', 'aid_choking_3'],
    illustrations: [
      'assets/illustrations/choking_adult_1.svg',
      'assets/illustrations/choking_adult_2.svg',
      'assets/illustrations/choking_adult_3.svg',
    ],
  ),
  _guide(
    'choking_child',
    'aid_choking_child',
    'aid_choking_summary',
    ['aid_choking_1', 'aid_choking_2', 'aid_choking_3'],
    sources: [_erc2025, _ercPaediatric2025],
    illustrations: [
      'assets/illustrations/assess.svg',
      'assets/illustrations/choking_child_back.svg',
      'assets/illustrations/choking_child_abdominal.svg',
    ],
  ),
  _guide(
    'choking_infant',
    'aid_choking_infant',
    'aid_choking_infant_summary',
    ['aid_infant_1', 'aid_infant_2', 'aid_infant_3'],
    sources: [_erc2025, _ercPaediatric2025],
    illustrations: [
      'assets/illustrations/assess.svg',
      'assets/illustrations/choking_infant_back.svg',
      'assets/illustrations/choking_infant_chest.svg',
    ],
  ),
  _guide('unconscious', 'aid_unconscious', 'aid_unconscious_summary', ['aid_unconscious_1', 'aid_unconscious_2', 'aid_unconscious_3']),
  _guide('bleeding', 'aid_bleeding', 'aid_bleeding_summary', ['aid_bleeding_1', 'aid_bleeding_2', 'aid_bleeding_3']),
  _guide('burn', 'aid_burn', 'aid_burn_summary', ['aid_burn_1', 'aid_burn_2', 'aid_burn_3']),
  _guide('trauma', 'aid_trauma', 'aid_trauma_summary', ['aid_trauma_1', 'aid_trauma_2', 'aid_trauma_3']),
  _guide('seizure', 'aid_seizure', 'aid_seizure_summary', ['aid_seizure_1', 'aid_seizure_2', 'aid_seizure_3']),
  _guide('drowning', 'aid_drowning', 'aid_drowning_summary', ['aid_drowning_1', 'aid_drowning_2', 'aid_drowning_3']),
  _guide('hypothermia', 'aid_hypothermia', 'aid_hypothermia_summary', ['aid_hypothermia_1', 'aid_hypothermia_2', 'aid_hypothermia_3']),
  _guide('heatstroke', 'aid_heatstroke', 'aid_heatstroke_summary', ['aid_heatstroke_1', 'aid_heatstroke_2', 'aid_heatstroke_3']),
  _guide('poisoning', 'aid_poisoning', 'aid_poisoning_summary', ['aid_poisoning_1', 'aid_poisoning_2', 'aid_poisoning_3']),
  _guide('anaphylaxis', 'aid_anaphylaxis', 'aid_anaphylaxis_summary', ['aid_anaphylaxis_1', 'aid_anaphylaxis_2', 'aid_anaphylaxis_3']),
];
