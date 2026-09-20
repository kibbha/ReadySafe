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
final _redCrossAbdominal = Uri.parse(
  'https://www.redcross.org/take-a-class/resources/learn-first-aid/abdominal-injury',
);
final _redCrossBleeding = Uri.parse(
  'https://www.redcross.org/take-a-class/resources/learn-first-aid/bleeding-life-threatening-external',
);


FirstAidGuide _guide(
  String id,
  String title,
  String summary,
  List<String> steps, {
  List<Uri>? sources,
  List<String>? illustrations,
  List<String?>? headings,
  List<List<String>>? details,
  String? definitionTitle,
  String? definitionBody,
  List<String> warnings = const [],
  bool supportsCprMetronome = false,
  Set<int> cprPacingSteps = const {},
}) => FirstAidGuide(
  id: id,
  titleKey: title,
  summaryKey: summary,
  steps: [
    for (var i = 0; i < steps.length; i++)
      FirstAidStep(
        textKey: steps[i],
        headingKey: headings != null && i < headings.length ? headings[i] : null,
        detailKeys: details != null && i < details.length ? details[i] : const [],
        cprPacing: cprPacingSteps.contains(i),
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
  definitionTitleKey: definitionTitle,
  definitionBodyKey: definitionBody,
  warningKeys: warnings,
  supportsCprMetronome: supportsCprMetronome,
);

final firstAidGuides = [
  _guide('cpr_adult','aid_cpr_adult','aid_cpr_summary',['aid_cpr_1','aid_cpr_2','aid_cpr_3','aid_cpr_4'],sources:[_erc2025,_ercAdultBls2025],illustrations:['assets/illustrations/cpr_adult_1.svg','assets/illustrations/cpr_adult_2.svg','assets/illustrations/cpr_adult_3.svg','assets/illustrations/cpr_adult_4.svg'],supportsCprMetronome:true,cprPacingSteps:{1}),
  _guide('aed','aid_aed','aid_aed_summary',['aid_aed_1','aid_aed_2','aid_aed_3'],sources:[_erc2025,_ercAdultBls2025],illustrations:['assets/illustrations/aed_open.svg','assets/illustrations/aed_pads.svg','assets/illustrations/aed_shock.svg']),
  _guide('cpr_child','aid_cpr_child','aid_cpr_child_summary',['aid_child_cpr_1','aid_child_cpr_2','aid_child_cpr_3','aid_child_cpr_4'],sources:[_erc2025,_ercPaediatric2025],illustrations:['assets/illustrations/cpr_child_assess.svg','assets/illustrations/cpr_child_breaths.svg','assets/illustrations/cpr_child_compressions.svg','assets/illustrations/cpr_child_aed.svg'],supportsCprMetronome:true,cprPacingSteps:{2}),
  _guide('cpr_infant','aid_cpr_infant','aid_cpr_infant_summary',['aid_infant_cpr_1','aid_infant_cpr_2','aid_infant_cpr_3','aid_infant_cpr_4'],sources:[_erc2025,_ercPaediatric2025],illustrations:['assets/illustrations/cpr_infant_assess.svg','assets/illustrations/cpr_infant_breaths.svg','assets/illustrations/cpr_infant_compressions.svg','assets/illustrations/cpr_infant_aed.svg'],supportsCprMetronome:true,cprPacingSteps:{2}),
  _guide('choking_adult','aid_choking_adult','aid_choking_summary',['aid_choking_1','aid_choking_2','aid_choking_3'],illustrations:['assets/illustrations/choking_adult_1.svg','assets/illustrations/choking_adult_2.svg','assets/illustrations/choking_adult_3.svg']),
  _guide('choking_child','aid_choking_child','aid_choking_summary',['aid_choking_1','aid_choking_2','aid_choking_3'],sources:[_erc2025,_ercPaediatric2025],illustrations:['assets/illustrations/choking_child_assess.svg','assets/illustrations/choking_child_back.svg','assets/illustrations/choking_child_abdominal.svg']),
  _guide('choking_infant','aid_choking_infant','aid_choking_infant_summary',['aid_infant_1','aid_infant_2','aid_infant_3'],sources:[_erc2025,_ercPaediatric2025],illustrations:['assets/illustrations/choking_infant_assess.svg','assets/illustrations/choking_infant_back.svg','assets/illustrations/choking_infant_chest.svg']),
  _guide('unconscious','aid_unconscious','aid_unconscious_summary',['aid_unconscious_1','aid_unconscious_2','aid_unconscious_3'],sources:[_erc2025,_ercAdultBls2025,_ercFirstAid2025],illustrations:['assets/illustrations/unconscious_assess.svg','assets/illustrations/unconscious_call.svg','assets/illustrations/unconscious_recovery.svg'],definitionTitle:'aid_pls_definition_title',definitionBody:'aid_pls_definition_body',warnings:['aid_pls_warning']),
  _guide('bleeding','aid_bleeding','aid_bleeding_summary',['aid_bleeding_1','aid_bleeding_2','aid_bleeding_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/bleeding_pressure.svg','assets/illustrations/bleeding_dressing.svg','assets/illustrations/bleeding_tourniquet.svg']),
  _guide(
    'wounds',
    'aid_wounds',
    'aid_wounds_summary',
    ['aid_wounds_chest', 'aid_wounds_abdomen', 'aid_wounds_embedded'],
    sources: [_erc2025, _ercFirstAid2025, _redCrossAbdominal, _redCrossBleeding],
    headings: [
      'aid_wounds_chest_heading',
      'aid_wounds_abdomen_heading',
      'aid_wounds_embedded_heading',
    ],
    details: [
      ['aid_wounds_chest_detail'],
      ['aid_wounds_abdomen_detail'],
      ['aid_wounds_embedded_detail'],
    ],
    illustrations: [
      'assets/illustrations/wounds_chest.svg',
      'assets/illustrations/wounds_abdomen.svg',
      'assets/illustrations/wounds_embedded.svg',
    ],
    warnings: ['aid_wounds_warning'],
  ),
  _guide(
    'waiting_positions',
    'aid_waiting_positions',
    'aid_waiting_positions_summary',
    [
      'aid_waiting_positions_chest',
      'aid_waiting_positions_abdomen',
      'aid_waiting_positions_unconscious',
      'aid_waiting_positions_trauma',
    ],
    sources: [_erc2025, _ercFirstAid2025, _redCrossAbdominal],
    headings: [
      'aid_waiting_positions_chest_heading',
      'aid_waiting_positions_abdomen_heading',
      'aid_waiting_positions_unconscious_heading',
      'aid_waiting_positions_trauma_heading',
    ],
    illustrations: [
      'assets/illustrations/waiting_chest.svg',
      'assets/illustrations/waiting_abdomen.svg',
      'assets/illustrations/waiting_recovery.svg',
      'assets/illustrations/waiting_trauma.svg',
    ],
    warnings: ['aid_waiting_positions_warning'],
  ),
  _guide('burn','aid_burn','aid_burn_summary',['aid_burn_1','aid_burn_2','aid_burn_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/burn_cool.svg','assets/illustrations/burn_cover.svg','assets/illustrations/burn_help.svg']),
  _guide('trauma','aid_trauma','aid_trauma_summary',['aid_trauma_1','aid_trauma_2','aid_trauma_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/trauma_safe.svg','assets/illustrations/trauma_stabilise.svg','assets/illustrations/trauma_call.svg']),
  _guide('seizure','aid_seizure','aid_seizure_summary',['aid_seizure_1','aid_seizure_2','aid_seizure_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/seizure_protect.svg','assets/illustrations/seizure_recovery.svg','assets/illustrations/seizure_call.svg']),
  _guide('drowning','aid_drowning','aid_drowning_summary',['aid_drowning_1','aid_drowning_2','aid_drowning_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/drowning_rescue.svg','assets/illustrations/drowning_breaths.svg','assets/illustrations/drowning_cpr.svg']),
  _guide('hypothermia','aid_hypothermia','aid_hypothermia_summary',['aid_hypothermia_1','aid_hypothermia_2','aid_hypothermia_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/hypothermia_shelter.svg','assets/illustrations/hypothermia_dry.svg','assets/illustrations/hypothermia_warm.svg']),
  _guide('heatstroke','aid_heatstroke','aid_heatstroke_summary',['aid_heatstroke_1','aid_heatstroke_2','aid_heatstroke_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/heatstroke_recognise.svg','assets/illustrations/heatstroke_cool.svg','assets/illustrations/heatstroke_call.svg']),
  _guide('poisoning','aid_poisoning','aid_poisoning_summary',['aid_poisoning_1','aid_poisoning_2','aid_poisoning_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/poisoning_safe.svg','assets/illustrations/poisoning_call.svg','assets/illustrations/poisoning_monitor.svg']),
  _guide('anaphylaxis','aid_anaphylaxis','aid_anaphylaxis_summary',['aid_anaphylaxis_1','aid_anaphylaxis_2','aid_anaphylaxis_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/anaphylaxis_recognise.svg','assets/illustrations/anaphylaxis_adrenaline.svg','assets/illustrations/anaphylaxis_call.svg']),
  _guide('stroke','aid_stroke','aid_stroke_summary',['aid_stroke_1','aid_stroke_2','aid_stroke_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/stroke_face.svg','assets/illustrations/stroke_arm.svg','assets/illustrations/stroke_call.svg']),
  _guide('chest_pain','aid_chest_pain','aid_chest_pain_summary',['aid_chest_pain_1','aid_chest_pain_2','aid_chest_pain_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/chest_pain_assess.svg','assets/illustrations/chest_pain_rest.svg','assets/illustrations/chest_pain_call.svg']),
  _guide('asthma','aid_asthma','aid_asthma_summary',['aid_asthma_1','aid_asthma_2','aid_asthma_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/asthma_inhaler.svg','assets/illustrations/asthma_sit.svg','assets/illustrations/asthma_call.svg']),
  _guide('hypoglycemia','aid_hypoglycemia','aid_hypoglycemia_summary',['aid_hypoglycemia_1','aid_hypoglycemia_2','aid_hypoglycemia_3'],sources:[_erc2025,_ercFirstAid2025],illustrations:['assets/illustrations/hypoglycemia_sugar.svg','assets/illustrations/hypoglycemia_monitor.svg','assets/illustrations/hypoglycemia_call.svg']),
];
