import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bank_app/widgets/items/service_item.dart';

import '../../routes/manage_auth_nav.dart';
import '../../widgets/common/custom_card.dart';

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
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomCard(
                  label: 'Главная',
                ),
                SizedBox(height: size.height * 0.02),
                CustomCard(
                  child: Row(
                    children: [
                      ServiceItem(
                        svgPath: controller.homeIconPaths[0],
                        label: 'Карты',
                        iconSize: 32,
                        onTap: () => manageNav(
                            false,
                            () => Get.toNamed('/createAccount',
                                arguments: 'card')),
                      ),
                      ServiceItem(
                          svgPath: controller.homeIconPaths[1],
                          label: 'Депозиты',
                          iconSize: 32,
                          onTap: () => manageNav(
                                false,
                                () => Get.toNamed('/createAccount',
                                    arguments: 'deposit'),
                              )),
                      ServiceItem(
                        svgPath: controller.homeIconPaths[2],
                        label: 'Кредиты',
                        iconSize: 32,
                        onTap: () => manageNav(
                            false,
                            () => Get.toNamed('/createAccount',
                                arguments: 'credit')),
                      ),
                      ServiceItem(
                        svgPath: controller.homeIconPaths[3],
                        label: 'Рассрочка',
                        iconSize: 32,
                        onDoubleTap: () => {Get.toNamed('/testing')},
                      ),
                    ],
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
}
