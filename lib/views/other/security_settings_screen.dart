import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../shared/shared_classes.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  SecuritySettingsScreenState createState() => SecuritySettingsScreenState();
}

class SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final List<MenuSection> sections = [
    MenuSection(
      title: null,
      items: [
        MenuItem(icon: 'assets/icons/ic_lock.svg', title: 'Смена пароля'),
        MenuItem(
            icon: 'assets/icons/ic_accounts.svg', title: 'Связанные аккаунты'),
        MenuItem(
          icon: 'assets/icons/ic_access_code.svg',
          title: 'Изменить код доступа',
        ),
        MenuItem(
            icon: 'assets/icons/ic_fingerprint.svg',
            title: 'Авторизация',
            description: 'Вход в приложение с биометрией'),
        MenuItem(
            icon: 'assets/icons/ic_screen_protect.svg',
            title: 'Защита от записи экрана',
            description: 'Скриншоты, запись и демонстрация экрана'),
        MenuItem(
            icon: 'assets/icons/ic_face.svg',
            title: 'Операции с биометрией',
            description: 'Подтверждение переводов'),
      ],
    ),
  ];

  // A map to store the state of each toggleable item
  final Map<String, bool> switchStates = {
    'assets/icons/ic_fingerprint.svg': true,
    'assets/icons/ic_screen_protect.svg': false,
    'assets/icons/ic_face.svg': true,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/ic_back.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Безопасность',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: Column(
                children: [
                  ...sections.map((section) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (section.title != null)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      section.title!,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ...section.items.map((item) => _buildMenuItem(
                                      item: item,
                                      theme: theme,
                                      isLast: section.items.last == item,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      )),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Запросить удаление учётной записи',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required MenuItem item,
    required ThemeData theme,
    bool isLast = false,
  }) {
    bool shouldShowSwitch = switchStates.containsKey(item.icon);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            child: InkWell(
              onTap: shouldShowSwitch
                  ? () {
                      setState(() {
                        switchStates[item.icon] =
                            !(switchStates[item.icon] ?? false);
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(12), // Soft rounded corners
              splashFactory: InkRipple.splashFactory, // Smoother ripple effect
              splashColor: theme.colorScheme.primary.withOpacity(0.08),
              highlightColor: theme.colorScheme.primary.withOpacity(0.04),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      item.icon,
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: item.description == null
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                          if (item.description != null) ...[
                            SizedBox(height: 4),
                            Text(
                              item.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (shouldShowSwitch)
                      Switch(
                        value: switchStates[item.icon] ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            switchStates[item.icon] = value;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.secondaryContainer,
          ),
      ],
    );
  }
}
