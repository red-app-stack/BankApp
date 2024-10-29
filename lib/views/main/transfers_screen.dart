//transfers_screen.dart // page 2
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/themes/theme_extension.dart';

class TransfersController extends GetxController {
  final List<String> transferIconPaths = [
    'assets/icons/ic_phone.svg',
    'assets/icons/ic_transfer.svg',
    'assets/icons/ic_geolocation.svg',
    'assets/icons/ic_worldwide.svg',
    'assets/icons/ic_convert.svg',
    'assets/icons/ic_qr.svg',
    'assets/icons/ic_bank.svg',
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
                    padding: EdgeInsets.all(6),
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
                        icon: controller.transferIconPaths[0],
                        title: 'По номеру телефона',
                        description:
                            'Клиентам и предпринимателям, в другие банки',
                        onTap: () => _handleTransferItemTap(context, 'phone'),
                      ),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                        context: context,
                        icon: controller.transferIconPaths[1],
                        title: 'Между своими счетами',
                        description: 'Картами, счетами, депозитами',
                        onTap: () => _handleTransferItemTap(context, 'self'),
                      ),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                        context: context,
                        icon: controller.transferIconPaths[2],
                        title: 'Внутри Казахстана',
                        description: 'На карту, на номер счёта',
                        onTap: () => _handleTransferItemTap(context, 'kz'),
                      ),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                        context: context,
                        icon: controller.transferIconPaths[3],
                        title: 'Международные переводы',
                        description: 'В любую точку мира',
                        onTap: () => _handleTransferItemTap(context, 'world'),
                      ),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                        context: context,
                        icon: controller.transferIconPaths[4],
                        title: 'Конвертация',
                        description: 'Конвертация валют',
                        onTap: () => _handleTransferItemTap(context, 'convert'),
                      ),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                        context: context,
                        icon: controller.transferIconPaths[5],
                        title: 'Bank QR',
                        description: 'Создайте QR для получения перевода',
                        onTap: () => _handleTransferItemTap(context, 'qr'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
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
                        _buildSavedItem(
                          svgPath: 'assets/icons/ic_bank.svg',
                          svgPathSub: 'assets/icons/visa.svg',
                          title: 'Bank',
                          subtitle: '• 1488',
                          theme: theme,
                        )
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
      borderRadius: BorderRadius.circular(12),
      splashFactory: InkRipple.splashFactory,
      splashColor: theme.colorScheme.primary.withOpacity(0.08),
      highlightColor: theme.colorScheme.primary.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.extension<CustomColors>()!.primaryVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
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

  Widget _buildSavedItem({
    required String svgPath,
    required String? svgPathSub,
    required String title,
    required String subtitle,
    required ThemeData theme,
    double iconSize = 30,
  }) {
    return Material(
        color: Colors.transparent,
        child: Ink(
            child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                splashColor: theme.colorScheme.primary.withOpacity(0.08),
                highlightColor: theme.colorScheme.primary.withOpacity(0.04),
                child: Padding(
                  padding: EdgeInsets.all(8),
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
                            Text(title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary)),
                            Row(
                              children: [
                                svgPathSub != null
                                    ? SvgPicture.asset(
                                        svgPathSub,
                                        width: 30,
                                        height: 12,
                                      )
                                    : SizedBox(),
                                SizedBox(width: 8),
                                Text(subtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme
                                          .extension<CustomColors>()!
                                          .primaryVariant,
                                    ))
                              ],
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
                ))));
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
