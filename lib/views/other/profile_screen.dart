import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/themes/theme_extension.dart';
import '../shared/shared_classes.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  final VoidCallback onBack;

  final List<MenuSection> sections = [
    MenuSection(
      title: 'Мои уведомления',
      items: [
        MenuItem(
            icon: 'assets/icons/ic_transactions.svg',
            title: 'Операции по счетам',
            description: 'Пополнение карты *1488 на 48180.20KZT.'),
        MenuItem(
            icon: 'assets/icons/ic_transfers.svg',
            title: 'Переводы',
            description: '13:24 Перевод 18000.00KZT с карты *5269'),
        MenuItem(
            icon: 'assets/icons/ic_payments.svg',
            title: 'Платежи',
            description: 'Пополнение 7550.00KZT TulparCard 5465345466'),
        MenuItem(
            icon: 'assets/icons/ic_security.svg',
            title: 'Безопасность',
            description:
                'Не переходите по непроверенным ссылкам и не вводите свои личные данные на неизвестных сайтах. Мошенники могут использовать поддельные ссылки и страницы для кражи информации. Всегда проверяйте источник сообщений и убедитесь, что адрес веб-сайта принадлежит вашему банку. Помните: сотрудники банка никогда не будут запрашивать ваш пароль или код из SMS.')
      ],
    ),
    MenuSection(
      title: 'Настройки',
      items: [
        MenuItem(
            icon: 'assets/icons/ic_notifications.svg', title: 'Уведомления'),
        MenuItem(
            icon: 'assets/icons/ic_language.svg', title: 'Язык приложения'),
        MenuItem(
            icon: 'assets/icons/ic_smartphone.svg',
            title: '+7 (707) 2****05',
            description: 'Ваш доверенный номер'),

        MenuItem(
            icon: 'assets/icons/ic_phone.svg',
            title: 'Переводы по номеру телефона'),
      ],
    ),
  ];

  ProfileScreen({
    super.key,
    required this.onBack,
  }) {
    Get.lazyPut(() => ThemeController());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Center(
                child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Профиль',
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(alignment: Alignment.center, children: [
                          CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              child: Container()),
                          Text(
                            'ВВ',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ]),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          'Владислав\nВасильевич Ш.',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
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
                SizedBox(height: size.height * 0.03),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required MenuItem item,
    required ThemeData theme,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              splashFactory: InkRipple.splashFactory,
              splashColor: theme.colorScheme.primary.withOpacity(0.08),
              highlightColor: theme.colorScheme.primary.withOpacity(0.04),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          item.icon,
                          width: 40,
                          height: 40,
                        ),
                        if (item.icon == 'assets/icons/ic_transactions.svg' ||
                            item.icon == 'assets/icons/ic_transfers.svg' ||
                            item.icon == 'assets/icons/ic_payments.svg' ||
                            item.icon == 'assets/icons/ic_security.svg')
                          Positioned(
                            top: -3,
                            right: -3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme
                                    .extension<CustomColors>()!
                                    .notifications,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
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
