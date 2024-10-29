//transfers_screen.dart // page 2
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TransfersController extends GetxController {
  final List<String> homeIconPaths = [
    'assets/icons/creditcard.svg',
    'assets/icons/deposit.svg',
    'assets/icons/credit.svg',
    'assets/icons/installment.svg',
  ];

  final List<String> popularIconPaths = [
    'assets/icons/phone.svg',
    'assets/icons/internet.svg',
    'assets/icons/transport.svg',
    'assets/icons/valve.svg',
  ];
}

class TransfersScreen extends StatelessWidget {
  final TransfersController controller = Get.put(TransfersController());

  TransfersScreen({super.key});

  void _handleTransferItemTap(BuildContext context, String type) {
    switch (type) {
      case 'phone':
        Get.toNamed('/phoneTransfer');
        break;
      case 'self':
        Get.toNamed('/phoneTransfer');

        break;
      case 'domestic':
        Get.toNamed('/phoneTransfer');

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Переводы',
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
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardItem(
                        context: context,
                        icon: 'assets/icons/phone.svg',
                        title: 'По номеру телефона',
                        description:
                            'Клиентам и предпринимателям, в другие банки',
                        onTap: () => _handleTransferItemTap(context, 'phone'),
                      ),
                      Divider(height: 1),
                      _buildCardItem(
                        context: context,
                        icon: 'assets/icons/card.svg',
                        title: 'Между своими счетами',
                        description: 'Картами, счетами, депозитами',
                        onTap: () => _handleTransferItemTap(context, 'self'),
                      ),
                      Divider(height: 1),
                      _buildCardItem(
                        context: context,
                        icon: 'assets/icons/card.svg',
                        title: 'Внутри Казахстана',
                        description: 'На карту, на номер счёта',
                        onTap: () =>
                            _handleTransferItemTap(context, 'domestic'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
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
