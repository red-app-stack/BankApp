import 'dart:math';
import 'dart:ui';

import 'package:bank_app/utils/themes/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../controllers/accounts_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import '../shared/formatters.dart';

class BankCard {
  final String name;
  final String type;
  final String number;
  final String? tengeBalance;
  final String? usdBalance;
  final String? euroBalance;
  final String color;

  BankCard({
    required this.name,
    required this.type,
    required this.number,
    required this.tengeBalance,
    required this.usdBalance,
    required this.euroBalance,
    required this.color,
  });
}

class AccountsScreenController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final AccountsController accountsController = Get.find<AccountsController>();
  final AuthController _authController = Get.find<AuthController>();

  bool get isLoggedIn => _authController.isLoggedIn;
  var currentPage = 0.obs;

  List<BankCard> get bankCards => accountsController.accounts
      .map((account) => BankCard(
            name: userService.currentUser?.fullName ?? '',
            type: 'VISA ${account.accountType}',
            number: account.accountNumber,
            tengeBalance: account.currency == 'KZT'
                ? formatCurrency(
                    account.balance, 'KZT', currentLocale.toString())
                : null,
            usdBalance: account.currency == 'USD'
                ? formatCurrency(
                    account.balance, 'USD', currentLocale.toString())
                : null,
            euroBalance: account.currency == 'EUR'
                ? formatCurrency(
                    account.balance, 'EUR', currentLocale.toString())
                : null,
            color: _getCardColor(account.accountType),
          ))
      .toList();

  String _getCardColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'credit':
        return 'primary';
      case 'deposit':
        return 'secondary';
      case 'card':
        return 'tertiary';
      default:
        return 'gray';
    }
  }

  @override
  void onInit() {
    super.onInit();
    accountsController.fetchAccounts();
  }

  void onPageChanged(int index) {
    currentPage.value = index % bankCards.length;
  }
}

class CardPromoItem {
  final String banner;
  final String title;
  final String info;

  CardPromoItem({
    required this.banner,
    required this.title,
    required this.info,
  });
}

class AccountsScreen extends StatelessWidget {
  final AccountsScreenController _controller =
      Get.put(AccountsScreenController());

  AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Счета',
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Карты',
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            _controller.bankCards.length > 1
                                ? Obx(() => SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3, // Constrain width
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          _controller.accountsController
                                              .accounts.length,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            width:
                                                _controller.currentPage.value ==
                                                        index
                                                    ? 16
                                                    : 8,
                                            height: 8,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape
                                                  .circle, // Keep circle shape for inactive
                                              color: _controller
                                                          .currentPage.value ==
                                                      index
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.primary
                                                      .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          height: size.width > size.height
                              ? size.height * 0.6
                              : null,
                          child: Swiper(
                            physics: _controller.bankCards.length <= 1
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            loop: _controller.bankCards.length > 1,
                            allowImplicitScrolling:
                                _controller.bankCards.length > 1,
                            itemCount: _controller.bankCards.length,
                            itemBuilder: (context, index) {
                              final card = _controller.bankCards[index];
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  double cardWidth = constraints.maxWidth;
                                  if (size.width > size.height) {
                                    cardWidth = min(400, size.width * 0.7);
                                  }
                                  return Center(
                                    child: SizedBox(
                                      width: cardWidth,
                                      child: AspectRatio(
                                        aspectRatio: 1.586,
                                        child: _buildBankCard(
                                            context: context, card: card),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            onIndexChanged: _controller.onPageChanged,
                            layout: SwiperLayout.TINDER,
                            itemWidth: size.width * 0.85,
                            itemHeight: size.width *
                                0.85 /
                                1.586, // Correct aspect ratio
                            scale: 0.5,
                            viewportFraction: 0.5,
                            curve: Curves.easeInOut,
                            index: _controller.currentPage.value,
                            duration: 400,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.secondaryContainer),
                      _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Открыть новую карту',
                          description: null,
                          onTap: () {
                            Get.toNamed('/createAccount');
                          }),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Кредиты',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Оформить кредит наличными',
                          description: 'Онлайн до 7 000 000 тенге',
                          onTap: () {}),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Депозиты',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Открыть депозит',
                          description: 'На выгодных условиях',
                          onTap: () {}),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/illustration_accounts.svg',
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                !_controller._authController.isLoggedIn
                    ? BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard({
    required BuildContext context,
    required BankCard card,
  }) {
    final size = MediaQuery.of(context).size;
    var width = (size.width > size.height) ? size.height : size.width;
    final theme = Theme.of(context);
    final Color colorBg = card.color == 'primary'
        ? theme.extension<CustomColors>()!.primaryCardBg!
        : card.color == 'secondary'
            ? theme.extension<CustomColors>()!.secondaryCardBg!
            : card.color == 'tertiary'
                ? theme.extension<CustomColors>()!.tertiaryCardBg!
                : theme.extension<CustomColors>()!.grayCardBg!;
    final Color colorFg = card.color == 'primary'
        ? theme.extension<CustomColors>()!.primaryCardFg!
        : card.color == 'secondary'
            ? theme.extension<CustomColors>()!.secondaryCardFg!
            : card.color == 'tertiary'
                ? theme.extension<CustomColors>()!.tertiaryCardFg!
                : theme.extension<CustomColors>()!.grayCardFg!;
    return Container(
        constraints: BoxConstraints(
          maxWidth: width * 0.2,
        ),
        decoration: BoxDecoration(
          color: colorBg,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1.586,
          child: Stack(
            children: [
              Positioned(
                top: -width * 0.136,
                right: -width * 0.19,
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorFg,
                  ),
                ),
              ),
              Positioned(
                top: -width * 0.057,
                left: -width * 0.296,
                child: Container(
                  width: width * 0.808,
                  height: width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorFg,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.userService.currentUser?.fullName ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Text(
                      card.type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      card.number,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              card.tengeBalance != null
                                  ? Text(
                                      card.tengeBalance ?? '₸ 0.00',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    )
                                  : Container(),
                              card.usdBalance != null
                                  ? Text(
                                      card.usdBalance ?? '\$ 0.00',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    )
                                  : Container(),
                              card.euroBalance != null
                                  ? Text(
                                      card.euroBalance ?? '€ 0.00',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(
                          "assets/icons/visa.svg",
                          width: 50,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCardItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String? description,
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
                  description != null
                      ? Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.extension<CustomColors>()!.primaryVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
