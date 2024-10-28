import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Настройки'),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text('Тема приложения'),
                subtitle: Text('Выберите светлую, тёмную или системную тему'),
                trailing: Obx(() => DropdownButton<ThemeMode>(
                      value: themeController.themeMode.value,
                      onChanged: (ThemeMode? newThemeMode) {
                        if (newThemeMode != null) {
                          if (newThemeMode == ThemeMode.system) {
                            themeController.setSystemTheme(context);
                          } else {
                            themeController.toggleTheme(context);
                          }
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Системная'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Светлая'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Тёмная'),
                        ),
                      ],
                    )),
              ),
              Divider(),
              ListTile(
                title: Text('Быстрое переключение темы'),
                subtitle: Text(
                    'Нажмите для переключения между светлой и тёмной темой'),
                trailing: ThemeSwitcher.withTheme(
                  builder: (_, switcher, theme) => IconButton(
                    icon: Icon(theme.brightness == Brightness.light
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    onPressed: () => themeController.toggleTheme(context),
                  ),
                ),
              ),
              Divider(),
              // Add more settings options here
            ],
          ),
        ),
      ),
    );
  }
}
