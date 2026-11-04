import '../core/search_text.dart';

enum FieldGuideCategory { plants, mushrooms, skills }

/// Offline reference only. A field guide cannot certify edibility or safety.
class FieldGuideEntry {
  const FieldGuideEntry({
    required this.id,
    required this.category,
    required this.titleFr,
    required this.titleEn,
    required this.summaryFr,
    required this.summaryEn,
    required this.warningFr,
    required this.warningEn,
    required this.stepsFr,
    required this.stepsEn,
    required this.scientificName,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final String id;
  final FieldGuideCategory category;
  final String titleFr;
  final String titleEn;
  final String summaryFr;
  final String summaryEn;
  final String warningFr;
  final String warningEn;
  final List<String> stepsFr;
  final List<String> stepsEn;
  final String scientificName;
  final String sourceLabel;
  final String sourceUrl;

  factory FieldGuideEntry.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid field-guide key: $key');
      }
      return value;
    }

    String optionalString(String key) => json[key] is String ? json[key] as String : '';

    List<String> steps(String key) {
      final value = json[key];
      if (value is! List || value.isEmpty || value.any((v) => v is! String || v.trim().isEmpty)) {
        throw FormatException('Invalid field-guide steps: $key');
      }
      return List<String>.unmodifiable(value.cast<String>());
    }

    final categoryName = requiredString('category');
    final category = FieldGuideCategory.values.where((c) => c.name == categoryName);
    if (category.isEmpty) throw FormatException('Unknown category: $categoryName');

    final sourceUrl = requiredString('source_url');
    if (Uri.tryParse(sourceUrl)?.isScheme('https') != true) {
      throw const FormatException('Sources must use HTTPS');
    }

    return FieldGuideEntry(
      id: requiredString('id'),
      category: category.first,
      titleFr: requiredString('title_fr'),
      titleEn: requiredString('title_en'),
      summaryFr: requiredString('summary_fr'),
      summaryEn: requiredString('summary_en'),
      warningFr: requiredString('warning_fr'),
      warningEn: requiredString('warning_en'),
      stepsFr: steps('steps_fr'),
      stepsEn: steps('steps_en'),
      scientificName: optionalString('scientific_name'),
      sourceLabel: requiredString('source_label'),
      sourceUrl: sourceUrl,
    );
  }

  String title(bool en) => en ? titleEn : titleFr;
  String summary(bool en) => en ? summaryEn : summaryFr;
  String warning(bool en) => en ? warningEn : warningFr;
  List<String> steps(bool en) => en ? stepsEn : stepsFr;

  bool matches(String query, bool en) {
    final words = normalizeSearchText(query);
    if (words.isEmpty) return true;
    final content = normalizeSearchText([
      id,
      scientificName,
      titleFr,
      titleEn,
      summaryFr,
      summaryEn,
      warningFr,
      warningEn,
      ...stepsFr,
      ...stepsEn,
    ].join(' '));
    return words.split(' ').every((word) => content.contains(word));
  }
}
