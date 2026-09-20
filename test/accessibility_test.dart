import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/accessibility.dart';

void main() {
  test('ReadySafe text scaler preserves the operating-system scale', () {
    final scaler = ReadySafeTextScaler(
      base: TextScaler.linear(1.5),
      multiplier: 1.0,
    );

    expect(scaler.scale(16), 24);
  });

  test('large-text boost composes with the operating-system scale', () {
    final scaler = ReadySafeTextScaler(
      base: TextScaler.linear(1.5),
      multiplier: 1.18,
    );

    expect(scaler.scale(16), closeTo(28.32, 0.001));
  });
}
