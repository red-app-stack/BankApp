import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../routes/manage_auth_nav.dart';
import '../../services/server_check_helper.dart';

class HomeScreenController extends GetxController {
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
    'assets/icons/utilities.svg',
  ];
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeScreenController controller = Get.put(HomeScreenController());

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
                              'Главная',
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
                    SizedBox(height: size.height * 0.08),
                    Center(
                      child: (theme.brightness == Brightness.dark)
                          ? Container()
                          : SvgPicture.asset(
                              'assets/icons/illustration_home.svg',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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
          onTap: () async {
            svgPath == 'assets/icons/creditcard.svg'
                ? {
                    manageNav(false,
                        () => Get.toNamed('/createAccount', arguments: 'card')),
                  }
                : svgPath == 'assets/icons/deposit.svg'
                    ? {
                        manageNav(
                          false,
                          () => Get.toNamed('/createAccount',
                              arguments: 'deposit'),
                        )
                      }
                    : svgPath == 'assets/icons/credit.svg'
                        ? {
                            manageNav(
                              false,
                              () => Get.toNamed('/createAccount',
                                  arguments: 'credit'),
                            )
                          }
                        : svgPath == 'assets/icons/installment.svg'
                            ? {
                                Get.toNamed('/testing')
                                //  print(await Get.find<ServerHealthService>().findWorkingServer())
                              }
                            : null;
          },
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
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
}
