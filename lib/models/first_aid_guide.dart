class FirstAidStep {
  const FirstAidStep({required this.textKey, this.illustrationAsset});
  final String textKey;
  final String? illustrationAsset;
}

class FirstAidGuide {
  const FirstAidGuide({
    required this.id,
    required this.titleKey,
    required this.summaryKey,
    required this.steps,
  });
  final String id;
  final String titleKey;
  final String summaryKey;
  final List<FirstAidStep> steps;
}
