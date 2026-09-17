class FirstAidStep {
  const FirstAidStep({required this.textKey, required this.illustrationAsset});
  final String textKey;
  final String illustrationAsset;
}

class FirstAidGuide {
  const FirstAidGuide({
    required this.id,
    required this.titleKey,
    required this.summaryKey,
    required this.steps,
    required this.sourceUris,
  });
  final String id, titleKey, summaryKey;
  final List<FirstAidStep> steps;
  final List<Uri> sourceUris;
}
