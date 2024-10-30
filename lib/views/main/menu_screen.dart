import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../shared/shared_classes.dart';

class MenuController extends GetxController {
  final RxDouble scrollOffset = 0.0.obs;
  final double collapsedHeight = 60.0;
  final double expandedHeight = 120.0;
}

class MenuScreen extends StatelessWidget {
  final MenuController controller = Get.put(MenuController());

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
      title: 'Банк',
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              controller.scrollOffset.value = scrollNotification.metrics.pixels;
            }
            return true;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Меню',
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
                        SizedBox(height: 16),
                      ],
                    )),
                _buildServiceItem(
                    svgPath: 'assets/icons/ic_exit.svg',
                    label: 'Выход',
                    theme: theme),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String svgPath,
    String label = '',
    double iconSize = 40,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12), // Soft rounded corners
          splashFactory: InkRipple.splashFactory, // Smoother ripple effect
          splashColor: theme.colorScheme.primary.withOpacity(0.08),
          highlightColor: theme.colorScheme.primary.withOpacity(0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      svgPath,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.inversePrimary,
                        BlendMode.srcIn,
                      ),
                    )),
                SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ) ??
                      Get.textTheme.bodyMedium,
                ),
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
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
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
                    // if (item.icon == 'assets/icons/notifications.svg')
                    //   Positioned(
                    //     top: -8,
                    //     right: -8,
                    //     child: Container(
                    //       width: 16,
                    //       height: 16,
                    //       decoration: BoxDecoration(
                    //         color:
                    //             theme.extension<CustomColors>()!.notifications,
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: Center(
                    //         child: Text(
                    //           '12',
                    //           style: theme.textTheme.bodySmall?.copyWith(
                    //             color: theme.colorScheme.onPrimary,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
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
