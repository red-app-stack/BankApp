import 'package:bank_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  Rx<ThemeData> themeData = AppTheme.darkTheme.obs;
  SharedPreferences? sp;

  @override
  Future<void> onInit() async {
    sp = await SharedPreferences.getInstance();
    super.onInit();
  }

  Future<void> loadThemeMode() async {
    String? savedTheme = sp!.getString('themeMode');
    themeMode.value = _themeModeFromString(savedTheme ?? 'system');
    _setTheme(themeMode.value);
  }

  ThemeData loadThemeData(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.system:
        if (WidgetsBinding.instance.window.platformBrightness ==
            Brightness.dark) {
          return AppTheme.darkTheme;
        } else {
          return AppTheme.lightTheme;
        }
      default:
        return AppTheme.darkTheme;
    }
  }

  void toggleThisTheme(ThemeMode newThemeMode, BuildContext context) {
    _setTheme(newThemeMode);
  }

  void toggleTheme(BuildContext context) {

    ThemeMode newThemeMode;

    if (themeMode.value == ThemeMode.system) {
      newThemeMode = WidgetsBinding.instance.window.platformBrightness == Brightness.light
          ? ThemeMode.dark
          : ThemeMode.light;
    } else {
      newThemeMode =
          themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }

    _setTheme(newThemeMode);

  }

  void setSystemTheme(BuildContext context) {
    _setTheme(ThemeMode.system);
    themeMode.value = ThemeMode.system;
    sp!.setBool('system', true);

  }

  void _setTheme(ThemeMode mode) {
    themeMode.value = mode;
    sp!.setString('themeMode', _themeModeToString(mode));
  }


  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}
