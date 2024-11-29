import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../utils/themes/theme_extension.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/items/service_item.dart';

class PaymentsController extends GetxController {
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

class PaymentsScreen extends StatelessWidget {
  final PaymentsController controller = Get.put(PaymentsController());

  PaymentsScreen({super.key});

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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomCard(
                  label: 'Платежи',
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  endWidget: TextButton(
                    onPressed: () {
                      Get.toNamed('/paymentHistory');
                    },
                    child: Text('История',
                        style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.primary) ??
                            theme.textTheme.bodyMedium),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                CustomCard(
                  label: 'Популярное',
                  labelSize: theme.textTheme.titleMedium?.fontSize,
                  endWidget: Text(
                    'г. Тараз',
                    style: theme.textTheme.bodyMedium,
                  ),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ServiceItem(
                              svgPath: controller.homeIconPaths[0],
                              label: 'Связь',
                              iconSize: 32,
                            ),
                            ServiceItem(
                              svgPath: controller.homeIconPaths[1],
                              label: 'Интернет',
                              iconSize: 32,
                            ),
                            ServiceItem(
                              svgPath: controller.homeIconPaths[2],
                              label: 'Транспорт',
                              iconSize: 32,
                            ),
                            ServiceItem(
                              svgPath: controller.homeIconPaths[3],
                              label: 'Ком. услуги',
                              iconSize: 32,
                            ),
                          ]),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Избранное',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: size.height * 0.02),
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
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildFavoriteItem({
    required String svgPath,
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
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme
                                    .extension<CustomColors>()!
                                    .primaryVariant,
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
                ))));
  }
}
