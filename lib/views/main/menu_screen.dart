import 'dart:async';

import 'package:bank_app/controllers/auth_controller.dart';
import 'package:bank_app/widgets/items/service_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/items/list_item.dart';
import '../shared/shared_classes.dart';

class MenuScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  MenuScreen({super.key});

  final List<MenuSection> sections = [
    MenuSection(title: null, items: [
      MenuItem(
        icon: 'assets/icons/ic_settings.svg',
        title: 'Настройки безопасности',
      )
    ]),
    MenuSection(
      title: 'Продукты',
      items: [
        MenuItem(icon: 'assets/icons/ic_card.svg', title: 'Карты'),
        MenuItem(icon: 'assets/icons/ic_deposit.svg', title: 'Депозиты'),
        MenuItem(icon: 'assets/icons/ic_credit.svg', title: 'Кредиты'),
        MenuItem(icon: 'assets/icons/ic_installment.svg', title: 'Рассрочка')
      ],
    ),
    MenuSection(
      title: 'Insight Bank',
      items: [
        MenuItem(icon: 'assets/icons/ic_atm.svg', title: 'Банкоматы'),
        MenuItem(icon: 'assets/icons/ic_branch.svg', title: 'Отделения'),
        MenuItem(icon: 'assets/icons/ic_phone.svg', title: 'Позвонить в Bank'),
      ],
    ),
  ];
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CustomCard(
                  label: 'Меню',
                ),
                SizedBox(height: size.height * 0.02),
                ...sections.map((section) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCard(
                          padding: EdgeInsets.zero,
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
                                    subtitle: item.description,
                                    showDivider: !(section.items.last == item),
                                    onTap: () => handleItemClick(item.icon),
                                  )),
                              // ...section.items.map((item) => _buildMenuItem(
                              //       item: item,
                              //       theme: theme,
                              //       isLast: section.items.last == item,
                              //       onDoubleTap: () {},
                              //       onTap: () {
                              //         item.icon ==
                              //                 'assets/icons/ic_settings.svg'
                              //             ? {
                              //                 Get.toNamed('/securitySettings'),
                              //               }
                              //             : {};
                              //       },
                              //     ))
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    )),
                ServiceItem(
                    svgPath: 'assets/icons/ic_exit.svg',
                    label: 'Выход',
                    iconSize: 40,
                    expanded: false,
                    onTap: () => _authController.logout()),
                // _buildServiceItem(theme: theme),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required MenuItem item,
    required ThemeData theme,
    bool isLast = false,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
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

shouldShowNotification(String icon) {
  return false;
}

handleItemClick(String icon) {
  icon == 'assets/icons/ic_settings.svg'
      ? {
          Get.toNamed('/securitySettings'),
        }
      : {};
}
