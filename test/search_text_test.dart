import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/core/search_text.dart';

void main() {
  test('search normalization is case and accent insensitive', () {
    expect(
      normalizeSearchText('  Brûlure  SÉVÈRE  '),
      'brulure severe',
    );
    expect(
      normalizeSearchText('Séisme · Genève · qualité'),
      'seisme · geneve · qualite',
    );
    expect(normalizeSearchText('Bâle'), 'bale');
  });
}
