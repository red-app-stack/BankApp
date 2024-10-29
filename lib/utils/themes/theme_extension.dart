import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? backgroundGradientStart;
  final Color? backgroundGradientEnd;
  final Color? primaryVariant;
  final Color? notifications;
  final Color? primaryCardBg;
  final Color? primaryCardFg;
  final Color? secondaryCardBg;
  final Color? secondaryCardFg;
  final Color? tertiaryCardBg;
  final Color? tertiaryCardFg;
  final Color? grayCardBg;
  final Color? grayCardFg;

  CustomColors({
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
    required this.primaryVariant,
    required this.notifications,
    required this.primaryCardBg,
    required this.primaryCardFg,
    required this.secondaryCardBg,
    required this.secondaryCardFg,
    required this.tertiaryCardBg,
    required this.tertiaryCardFg,
    required this.grayCardBg,
    required this.grayCardFg,
  });

  @override
  CustomColors copyWith(
      {Color? backgroundGradientStart, Color? backgroundGradientEnd}) {
    return CustomColors(
      backgroundGradientStart:
          backgroundGradientStart ?? backgroundGradientStart,
      backgroundGradientEnd: backgroundGradientEnd ?? backgroundGradientEnd,
      primaryVariant: primaryVariant ?? primaryVariant,
      notifications: notifications ?? notifications,
      primaryCardBg: primaryCardBg ?? primaryCardBg,
      primaryCardFg: primaryCardFg ?? primaryCardFg,
      secondaryCardBg: secondaryCardBg ?? secondaryCardBg,
      secondaryCardFg: secondaryCardFg ?? secondaryCardFg,
      tertiaryCardBg: tertiaryCardBg ?? tertiaryCardBg,
      tertiaryCardFg: tertiaryCardFg ?? tertiaryCardFg,
      grayCardBg: grayCardBg ?? grayCardBg,
      grayCardFg: grayCardFg ?? grayCardFg,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      backgroundGradientStart:
          Color.lerp(backgroundGradientStart, other.backgroundGradientStart, t),
      backgroundGradientEnd:
          Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t),
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t),
      notifications: Color.lerp(notifications, other.notifications, t),
      primaryCardBg: Color.lerp(primaryCardBg, other.primaryCardBg, t),
      primaryCardFg: Color.lerp(primaryCardFg, other.primaryCardFg, t),
      secondaryCardBg: Color.lerp(secondaryCardBg, other.secondaryCardBg, t),
      secondaryCardFg: Color.lerp(secondaryCardFg, other.secondaryCardFg, t),
      tertiaryCardBg: Color.lerp(tertiaryCardBg, other.tertiaryCardBg, t),
      tertiaryCardFg: Color.lerp(tertiaryCardBg, other.tertiaryCardFg, t),
      grayCardBg: Color.lerp(grayCardBg, other.grayCardBg, t),
      grayCardFg: Color.lerp(grayCardFg, other.grayCardFg, t),
    );
  }
}
