import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  final RxDouble scrollOffset = 0.0.obs;
  final double collapsedHeight = 60.0;
  final double expandedHeight = 120.0;
}

class MenuItem {
  final String icon;
  final String title;
  final String? description;
  final String? endElement;

  MenuItem({
    required this.icon,
    required this.title,
    this.description,
    this.endElement,
  });
}

class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({required this.title, required this.items});
}

class MenuScreen extends StatelessWidget {
  final MenuController controller = Get.put(MenuController());

  MenuScreen({super.key});

  final List<MenuSection> sections = [
    MenuSection(
      title: 'Кабинет',
      items: [
        MenuItem(
          icon: 'assets/icons/profile.svg',
          title: 'Профиль и настройки',
        ),
        MenuItem(
          icon: 'assets/icons/requests.svg',
          title: 'Мои заявки',
        ),
        MenuItem(
          icon: 'assets/icons/qr.svg',
          title: 'Bank QR',
        ),
        MenuItem(
          icon: 'assets/icons/notifications.svg',
          title: 'Уведомления',
          endElement: '12',
        ),
      ],
    ),
    MenuSection(
      title: 'Услуги',
      items: [
        MenuItem(
          icon: 'assets/icons/case.svg',
          title: 'Регистрация ИП',
        ),
        MenuItem(
          icon: 'assets/icons/document.svg',
          title: 'Получить справку',
          description: 'О наличии счета, доступном остатке',
        ),
      ],
    ),
    MenuSection(
      title: 'Продукты',
      items: [
        MenuItem(icon: 'assets/icons/creditcard.svg', title: 'Карты'),
        MenuItem(icon: 'assets/icons/deposit.svg', title: 'Депозиты'),
        MenuItem(icon: 'assets/icons/credit.svg', title: 'Кредиты'),
        MenuItem(icon: 'assets/icons/installment.svg', title: 'Рассрочка'),
        MenuItem(icon: 'assets/icons/travel.svg', title: 'Travel'),
        MenuItem(icon: 'assets/icons/invest.svg', title: 'Invest'),
        MenuItem(icon: 'assets/icons/market.svg', title: 'Маркет'),
        MenuItem(icon: 'assets/icons/insurance.svg', title: 'Страховка'),
      ],
    ),
    MenuSection(
      title: 'Привилегии',
      items: [
        MenuItem(
          icon: 'assets/icons/offer.svg',
          title: 'Персональные предложения',
        ),
        MenuItem(icon: 'assets/icons/club.svg', title: 'Bank Club'),
        MenuItem(icon: 'assets/icons/info.svg', title: 'Bank Info'),
        MenuItem(icon: 'assets/icons/promo.svg', title: 'Промо код'),
      ],
    ),
    MenuSection(
      title: 'Банк',
      items: [
        MenuItem(icon: 'assets/icons/atm.svg', title: 'Банкоматы'),
        MenuItem(icon: 'assets/icons/branch.svg', title: 'Отделения'),
        MenuItem(icon: 'assets/icons/phone.svg', title: 'Позвонить'),
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
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
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, sectionIndex) {
                      final section = sections[sectionIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              section.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Card(
                            child: Column(
                              children: section.items.map((item) {
                                return _buildMenuItem(
                                  item: item,
                                  theme: theme,
                                  isLast: section.items.last == item,
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                    childCount: sections.length,
                  ),
                ),
              ),
            ],
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
                SvgPicture.asset(
                  item.icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
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
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.endElement != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.endElement!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
          ),
      ],
    );
  }
}
