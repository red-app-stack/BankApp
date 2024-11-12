import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Builder(
      builder: (context) => Scaffold(
                backgroundColor: theme.brightness == Brightness.light
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
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
                        themeController.setThemeMode(newThemeMode);
                      }
                    },
                    items: const [
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
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.secondaryContainer,
            ),
            ListTile(
              title: Text('Быстрое переключение темы'),
              subtitle:
                  Text('Нажмите для переключения между светлой и тёмной темой'),
              trailing: IconButton(
                icon: Icon(theme.brightness == Brightness.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () => themeController.toggleTheme(context),
              ),
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.secondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
