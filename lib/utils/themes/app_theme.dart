import 'package:flutter/material.dart';
import 'app_colors_light.dart';
import 'app_colors_dark.dart';
import 'theme_extension.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        backgroundGradientStart: AppColorsLight.surfaceDim,
        backgroundGradientEnd: AppColorsLight.surface,
        primaryVariant: AppColorsLight.primaryVariant,
        background: AppColorsLight.background,
        notifications: AppColorsLight.notifications,
        primaryCardBg: AppColorsLight.primaryCardBg,
        primaryCardFg: AppColorsLight.primaryCardFg,
        secondaryCardBg: AppColorsLight.secondaryCardBg,
        secondaryCardFg: AppColorsLight.secondaryCardFg,
        tertiaryCardBg: AppColorsLight.tertiaryCardBg,
        tertiaryCardFg: AppColorsLight.tertiaryCardFg,
        grayCardBg: AppColorsLight.grayCardBg,
        grayCardFg: AppColorsLight.grayCardFg,
        yellowCardBg: AppColorsLight.yellowCardBg,
        yellowCardFg: AppColorsLight.yellowCardFg,
        purpleCardBg: AppColorsLight.purpleCardBg,
        purpleCardFg: AppColorsLight.purpleCardFg,
        goldCardBg: AppColorsLight.goldCardBg,
        goldCardFg: AppColorsLight.goldCardFg,
        redCardBg: AppColorsLight.redCardBg,
        redCardFg: AppColorsLight.redCardFg,
      ),
    ],
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColorsLight.primary,
      onPrimary: AppColorsLight.onPrimary,
      primaryContainer: AppColorsLight.primaryContainer,
      onPrimaryContainer: AppColorsLight.onPrimaryContainer,
      secondary: AppColorsLight.secondary,
      onSecondary: AppColorsLight.onSecondary,
      secondaryContainer: AppColorsLight.secondaryContainer,
      onSecondaryContainer: AppColorsLight.onSecondaryContainer,
      tertiary: AppColorsLight.tertiary,
      onTertiary: AppColorsLight.onTertiary,
      tertiaryContainer: AppColorsLight.tertiaryContainer,
      onTertiaryContainer: AppColorsLight.onTertiaryContainer,
      error: AppColorsLight.error,
      onError: AppColorsLight.onError,
      errorContainer: AppColorsLight.errorContainer,
      onErrorContainer: AppColorsLight.onErrorContainer,
      surface: AppColorsLight.surface,
      surfaceDim: AppColorsLight.surfaceDim,
      surfaceBright: AppColorsLight.surfaceBright,
      onSurface: AppColorsLight.onSurface,
      onSurfaceVariant: AppColorsLight.onSurfaceVariant,
      outline: AppColorsLight.outline,
      outlineVariant: AppColorsLight.outlineVariant,
      surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
      surfaceContainerLow: AppColorsLight.surfaceContainerLow,
      surfaceContainer: AppColorsLight.surfaceContainer,
      surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
      surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
      inversePrimary: AppColorsLight.inversePrimary,
      inverseSurface: AppColorsLight.inverseSurface,
      onInverseSurface: AppColorsLight.onInverseSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.primary,
      foregroundColor: AppColorsLight.onPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsLight.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsLight.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsLight.outline;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColorsLight.primary.withValues(alpha: 0.5);
            }
            return AppColorsLight.primary;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsLight.outlineVariant;
            }
            return AppColorsLight.onPrimary;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColorsLight.onPrimary.withValues(alpha: 0.3);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColorsLight.onPrimary.withValues(alpha: 0.1);
            }
            return null;
          },
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return 2.0;
            } else if (states.contains(WidgetState.hovered)) {
              return 8.0;
            }
            return 4.0;
          },
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColorsLight.onPrimary),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        )),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side:
            WidgetStateProperty.all(BorderSide(color: AppColorsLight.primary)),
        foregroundColor: WidgetStateProperty.all(AppColorsLight.primary),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        )),
      ),
    ),
    scaffoldBackgroundColor: AppColorsLight.surface,
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        backgroundGradientStart: AppColorsDark.primaryVariant,
        backgroundGradientEnd: AppColorsDark.onSecondary,
        primaryVariant: AppColorsDark.primaryVariantHigh,
        background: AppColorsDark.background,
        notifications: AppColorsDark.notifications,
        primaryCardBg: AppColorsDark.primaryCardBg,
        primaryCardFg: AppColorsDark.primaryCardFg,
        secondaryCardBg: AppColorsDark.secondaryCardBg,
        secondaryCardFg: AppColorsDark.secondaryCardFg,
        tertiaryCardBg: AppColorsDark.tertiaryCardBg,
        tertiaryCardFg: AppColorsDark.tertiaryCardFg,
        grayCardBg: AppColorsDark.grayCardBg,
        grayCardFg: AppColorsDark.grayCardFg,
        yellowCardBg: AppColorsDark.yellowCardBg,
        yellowCardFg: AppColorsDark.yellowCardFg,
        purpleCardBg: AppColorsDark.purpleCardBg,
        purpleCardFg: AppColorsDark.purpleCardFg,
        goldCardBg: AppColorsDark.goldCardBg,
        goldCardFg: AppColorsDark.goldCardFg,
        redCardBg: AppColorsDark.redCardBg,
        redCardFg: AppColorsDark.redCardFg,
      ),
    ],
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColorsDark.primary,
      onPrimary: AppColorsDark.onPrimary,
      primaryContainer: AppColorsDark.primaryContainer,
      onPrimaryContainer: AppColorsDark.onPrimaryContainer,
      secondary: AppColorsDark.secondary,
      onSecondary: AppColorsDark.onSecondary,
      secondaryContainer: AppColorsDark.secondaryContainer,
      onSecondaryContainer: AppColorsDark.onSecondaryContainer,
      tertiary: AppColorsDark.tertiary,
      onTertiary: AppColorsDark.onTertiary,
      tertiaryContainer: AppColorsDark.tertiaryContainer,
      onTertiaryContainer: AppColorsDark.onTertiaryContainer,
      error: AppColorsDark.error,
      onError: AppColorsDark.onError,
      errorContainer: AppColorsDark.errorContainer,
      onErrorContainer: AppColorsDark.onErrorContainer,
      surface: AppColorsDark.surface,
      surfaceDim: AppColorsDark.surfaceDim,
      surfaceBright: AppColorsDark.surfaceBright,
      onSurface: AppColorsDark.onSurface,
      onSurfaceVariant: AppColorsDark.onSurfaceVariant,
      outline: AppColorsDark.outline,
      outlineVariant: AppColorsDark.outlineVariant,
      surfaceContainerLowest: AppColorsDark.surfaceContainerLowest,
      surfaceContainerLow: AppColorsDark.surfaceContainerLow,
      surfaceContainer: AppColorsDark.surfaceContainer,
      surfaceContainerHigh: AppColorsDark.surfaceContainerHigh,
      surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
      inversePrimary: AppColorsDark.inversePrimary,
      inverseSurface: AppColorsDark.inverseSurface,
      onInverseSurface: AppColorsDark.onInverseSurface,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        color: AppColorsDark.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: 'OpenSans',
        color: AppColorsDark.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsDark.outline;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColorsDark.primary.withValues(alpha: 0.8);
            }
            return AppColorsDark.primary;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsDark.outlineVariant;
            }
            return AppColorsDark.onPrimary;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColorsDark.onPrimary.withValues(alpha: 0.3);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColorsDark.onPrimary.withValues(alpha: 0.1);
            }
            return null;
          },
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return 2.0;
            } else if (states.contains(WidgetState.hovered)) {
              return 8.0;
            }
            return 4.0;
          },
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColorsDark.onPrimary),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        )),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: AppColorsDark.primary)),
        foregroundColor: WidgetStateProperty.all(AppColorsDark.primary),
        textStyle: WidgetStateProperty.all(TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        )),
      ),
    ),
    scaffoldBackgroundColor: AppColorsDark.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: AppColorsDark.onPrimary,
    ),
  );
}
