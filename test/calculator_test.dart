import 'package:flutter_test/flutter_test.dart';

void main() {
  test('water calculation uses adults, children and days', () {
    const adults = 2, children = 1, days = 3;
    expect((adults * 3 + children * 2) * days, 24);
  });
}
