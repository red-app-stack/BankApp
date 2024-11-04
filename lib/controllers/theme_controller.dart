import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/shared/secure_store.dart';
import '../views/shared/user_settings.dart';


class ThemeController extends GetxController {
  final secureStore = Get.find<SecureStore>();
  var themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedSettings();
  }

  Future<void> loadSavedSettings() async {
    final settings = await secureStore.loadSettings();
    if (settings != null) {
      themeMode.value = settings.themeMode;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    saveThemeSettings();
  }

  Future<void> saveThemeSettings() async {
    final currentSettings = await secureStore.loadSettings() ?? UserSettings.defaults();
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode.value);
    await secureStore.saveSettings(updatedSettings);
    Get.changeThemeMode(themeMode.value);
  }

  void toggleTheme(BuildContext context) {
    setThemeMode(themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}