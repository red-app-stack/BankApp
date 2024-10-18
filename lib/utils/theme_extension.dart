import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? backgroundGradientStart;
  final Color? backgroundGradientEnd;

  CustomColors({
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
  });

  @override
  CustomColors copyWith({Color? backgroundGradientStart, Color? backgroundGradientEnd}) {
    return CustomColors(
      backgroundGradientStart: backgroundGradientStart ?? this.backgroundGradientStart,
      backgroundGradientEnd: backgroundGradientEnd ?? this.backgroundGradientEnd,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      backgroundGradientStart: Color.lerp(backgroundGradientStart, other.backgroundGradientStart, t),
      backgroundGradientEnd: Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t),
    );
  }
}
