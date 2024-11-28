import 'dart:async';
import 'dart:convert';

import 'package:bank_app/views/shared/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';
import '../../utils/themes/theme_extension.dart';
import '../shared/secure_store.dart';
import '../shared/widgets.dart';

class TransfersController extends GetxController {
  final SecureStore secureStore = Get.find<SecureStore>();
  RxList<Transaction> favorites = <Transaction>[].obs;
  static const String favoritesKey = 'favorite_transfers';

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<List<Transaction>> getFavoriteTransfers() async {
    final favoritesJson = await secureStore.secureRead(favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> loadFavorites() async {
    favorites.value = await getFavoriteTransfers();
  }

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
  final AccountsController accountsController = Get.find<AccountsController>();

  TransfersScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
    });
  }
  Future<void> refreshData() async {
    try {
      await controller.loadFavorites();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  void _handleTransferItemTap(BuildContext context, String type) {
    switch (type) {
      case 'phone':
        Get.toNamed('/phoneTransfer');
        break;
      case 'world':
        accountsController.addTestMoney(
            accountsController.accounts.first.accountNumber, 1000);
        break;
      case 'qr':
        Get.toNamed('/qrTransfer');
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
                await refreshData();

                await Future.delayed(const Duration(milliseconds: 500));
              } on TimeoutException {
                print('Refresh operation timed out');
              } catch (e) {
                print('Error during refresh: $e');
              } finally {
                // The next line should update the UI after the refresh is complete
              }
              return Future.value();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                              onPressed: () {
                                Get.toNamed('/transferHistory');
                              },
                              child: Text('История',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary) ??
                                      theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
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
                            onTap: () =>
                                _handleTransferItemTap(context, 'phone'),
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
                            onTap: () =>
                                _handleTransferItemTap(context, 'self'),
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
                            onTap: () =>
                                _handleTransferItemTap(context, 'world'),
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
                            onTap: () =>
                                _handleTransferItemTap(context, 'convert'),
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
                    SizedBox(height: size.height * 0.02),
                    Obx(() => controller.favorites.isNotEmpty
                        ? Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Избранное',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  ...controller.favorites
                                      .map((transaction) => _buildSavedItem(
                                            transaction: transaction,
                                            svgPath: null,
                                            svgPathSub: null,
                                            title: null,
                                            subtitle: null,
                                            theme: theme,
                                          )),
                                ],
                              ),
                            ),
                          )
                        : Container()),
                  ],
                ),
              ),
            )),
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

  Widget _buildSavedItem({
    required Transaction transaction,
    required String? svgPath,
    required String? svgPathSub,
    required String? title,
    required String? subtitle,
    required ThemeData theme,
    double iconSize = 30,
  }) {
    return Material(
        color: Colors.transparent,
        child: Ink(
            child: InkWell(
                onTap: () {
                  Get.toNamed('/transferDetails', arguments: transaction);
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                splashColor: theme.colorScheme.primary.withOpacity(0.08),
                highlightColor: theme.colorScheme.primary.withOpacity(0.04),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      svgPathSub != null
                          ? SvgPicture.asset(
                              svgPath!,
                              width: iconSize,
                              height: iconSize,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            )
                          : buildUserAvatar(theme, transaction.toUserName),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                title ?? formatFullName(transaction.toUserName),
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
                                Text(
                                    subtitle ??
                                        censorCardNumber(transaction.toAccount),
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
}
