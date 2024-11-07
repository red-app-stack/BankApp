import 'package:flutter/material.dart';

class UserSettings {
  final ThemeMode themeMode;
  final bool useBiometrics;
  final bool screenProtection;
  final bool biometricOperations;

  UserSettings({
    required this.themeMode,
    required this.useBiometrics,
    required this.screenProtection,
    required this.biometricOperations,
  });

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'useBiometrics': useBiometrics,
        'screenProtection': screenProtection,
        'biometricOperations': biometricOperations,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        themeMode: ThemeMode.values[json['themeMode']],
        useBiometrics: json['useBiometrics'],
        screenProtection: json['screenProtection'],
        biometricOperations: json['biometricOperations'],
      );

  UserSettings copyWith({
    ThemeMode? themeMode,
    bool? useBiometrics,
    bool? screenProtection,
    bool? biometricOperations,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      screenProtection: screenProtection ?? this.screenProtection,
      biometricOperations: biometricOperations ?? this.biometricOperations,
    );
  }

  factory UserSettings.defaults() => UserSettings(
        themeMode: ThemeMode.system,
        useBiometrics: false,
        screenProtection: true,
        biometricOperations: true,
      );
}
