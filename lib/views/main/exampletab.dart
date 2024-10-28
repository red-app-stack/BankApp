//payments_screen.dart // page 1
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PaymentsController extends GetxController {
  final List<String> homeIconPaths = [
    'assets/icons/creditcard.svg',
    'assets/icons/deposits.svg',
    'assets/icons/credits.svg',
    'assets/icons/shopping.svg',
  ];

  final List<String> popularIconPaths = [
    'assets/icons/phone.svg',
    'assets/icons/internet.svg',
    'assets/icons/transport.svg',
    'assets/icons/utilities.svg',
  ];
}

class PaymentsScreen extends StatelessWidget {
  final PaymentsController controller = Get.put(PaymentsController());

  PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // final PaymentsController controller = Get.put(PaymentsController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            hintText: 'Поиск...',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/support.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Tab name card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Платежи',
                          style: theme.textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('История',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary) ??
                                  theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Financial services card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[0],
                            label: 'Карты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[1],
                            label: 'Депозиты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[2],
                            label: 'Кредиты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[3],
                            label: 'Рассрочка',
                            theme: theme),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Popular services card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Популярное',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'г. Тараз',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildServiceItem(
                                svgPath: controller.popularIconPaths[0],
                                label: 'Связь',
                                theme: theme),
                            _buildServiceItem(
                                svgPath: controller.popularIconPaths[1],
                                label: 'Интернет',
                                theme: theme),
                            _buildServiceItem(
                                svgPath: controller.popularIconPaths[2],
                                label: 'Транспорт',
                                theme: theme),
                            _buildServiceItem(
                                svgPath: controller.popularIconPaths[3],
                                label: 'Ком. услуги',
                                theme: theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Favorites card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Избранное',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        _buildFavoriteItem(
                          svgPath: controller.popularIconPaths[0],
                          title: 'Мобильная связь',
                          subtitle: 'Beeline, +7 777 123 45 67',
                          theme: theme,
                        ),
                        _buildFavoriteItem(
                          svgPath: controller.popularIconPaths[1],
                          title: 'Домашний интернет',
                          subtitle: 'ID: 123456789',
                          theme: theme,
                        ),
                        _buildFavoriteItem(
                          svgPath: controller.popularIconPaths[3],
                          title: 'Коммунальные услуги',
                          subtitle: 'Лицевой счет: 987654321',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),
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
    double iconSize = 32,
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
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                        theme.colorScheme.primary,
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

  Widget _buildFavoriteItem({
    required String svgPath,
    required String title,
    required String subtitle,
    required ThemeData theme,
    double iconSize = 24,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            svgPath,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/other_horiz.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainer,
      highlightColor: theme.colorScheme.surfaceBright,
      period: Duration(seconds: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          // Заголовок "Профиль"
          Container(
            width: 200,
            height: theme.textTheme.headlineMedium!.fontSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 28),
          // Фото профиля
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 10),
          // Кнопка "Изменить фото профиля"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
          // Информационные карточки
          for (int i = 0; i < 4; i++) ...[
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
            ),
          ],
          SizedBox(height: 20),
          // Кнопка "Настройки"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
          // Кнопка "Выйти"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
