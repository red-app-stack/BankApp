import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../services/user_service.dart';
import '../../utils/themes/theme_extension.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/items/list_item.dart';
import '../shared/shared_classes.dart';
import '../shared/widgets.dart';

class ProfileScreen extends StatelessWidget {
  final UserService _userService = Get.find<UserService>();

  final VoidCallback onBack;

  final List<MenuSection> sections = [
    MenuSection(
      title: 'Мои уведомления',
      items: [
        MenuItem(
            icon: 'assets/icons/ic_transactions.svg',
            title: 'Операции по счетам',
            description: 'Пополнение карты *3487 на 18180.20KZT.'),
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
  bool showNotification(String icon) {
    return switch (icon) {
      'assets/icons/ic_transactions.svg' => true,
      'assets/icons/ic_transfers.svg' => true,
      'assets/icons/ic_payments.svg' => true,
      'assets/icons/ic_security.svg' => true,
      'assets/icons/ic_notifications.svg' => false,
      'assets/icons/ic_language.svg' => false,
      'assets/icons/ic_smartphone.svg' => false,
      'assets/icons/ic_phone.svg' => false,
      _ => false
    };
  }

  void handeItemClick(String icon) {
    switch (icon) {
      case 'assets/icons/ic_notifications.svg':
        // Handle notifications click
        break;
      case 'assets/icons/ic_language.svg':
        // Handle language click
        break;
      case 'assets/icons/ic_smartphone.svg':
        // Handle trusted phone number click
        break;
      case 'assets/icons/ic_phone.svg':
        // Handle phone transfer settings click
        // replace in future
        // print('CLICKED');
        // _authController.checkAuthStatus();
        break;
      case 'assets/icons/ic_transactions.svg':
        // Handle transactions click
        break;
      case 'assets/icons/ic_transfers.svg':
        // Handle transfers click
        break;
      case 'assets/icons/ic_payments.svg':
        // Handle payments click
        break;
      case 'assets/icons/ic_security.svg':
        // Handle security click
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
          } on TimeoutException {
            print('Refresh operation timed out');
          } catch (e) {
            print('Error during refresh: $e');
          }
          return Future.value();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Center(
                child: Column(
              children: [
                CustomCard(
                  label: 'Профиль',
                ),
                SizedBox(height: size.height * 0.02),
                buildUserCard(_userService, theme, size),
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
                              ...section.items.map((item) => ListItem(
                                    svgPath: item.icon,
                                    title: item.title,
                                    showNotification:
                                        showNotification(item.icon),
                                    showDivider: section.items.last == item,
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
    ));
  }
}
