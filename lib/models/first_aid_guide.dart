class FirstAidStep {
  const FirstAidStep({
    required this.textKey,
    required this.illustrationAsset,
    this.headingKey,
    this.detailKeys = const [],
  });

  /// Short imperative instruction used by the guided emergency mode.
  final String textKey;

  /// Optional section heading used by the complete poster/PDF renderer.
  final String? headingKey;

  /// Optional supporting bullets. These are intentionally separate from the
  /// short guided instruction so the emergency mode remains concise.
  final List<String> detailKeys;

  final String illustrationAsset;
}

class FirstAidGuide {
  const FirstAidGuide({
    required this.id,
    required this.titleKey,
    required this.summaryKey,
    required this.steps,
    required this.sourceUris,
    this.definitionTitleKey,
    this.definitionBodyKey,
    this.warningKeys = const [],
    this.supportsCprMetronome = false,
    this.guidelineVersion = 'ERC/SRC 2025',
    this.reviewedOn = '2026-09-20',
  });

  final String id;
  final String titleKey;
  final String summaryKey;
  final List<FirstAidStep> steps;
  final List<Uri> sourceUris;

  /// Optional definition box, for example the recovery position (PLS).
  final String? definitionTitleKey;
  final String? definitionBodyKey;

  /// High-priority safety warnings shown in the complete poster and PDF.
  final List<String> warningKeys;

  /// Enables the offline 100–120/min CPR pacing controls.
  final bool supportsCprMetronome;

  /// Human-readable medical baseline displayed with the references.
  final String guidelineVersion;
  final String reviewedOn;
}
