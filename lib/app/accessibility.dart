import 'package:flutter/widgets.dart';

/// Applies ReadySafe's optional accessibility boost on top of the text scaling
/// already chosen by the user at operating-system level.
///
/// This deliberately composes with [base] instead of replacing it, so Android
/// and iOS accessibility text settings remain authoritative.
class ReadySafeTextScaler extends TextScaler {
  const ReadySafeTextScaler({
    required this.base,
    this.multiplier = 1.0,
  }) : assert(multiplier > 0);

  final TextScaler base;
  final double multiplier;

  @override
  double scale(double fontSize) => base.scale(fontSize) * multiplier;

  @override
  double get textScaleFactor => scale(1.0);
}
