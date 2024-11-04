import 'dart:math';
import 'dart:ui';

import 'package:bank_app/utils/themes/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

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

class AccountsController extends GetxController {
  final UserService userService = Get.find<UserService>();
  late PageController pageController;
  final AuthController _authController = Get.find<AuthController>();
  bool get isLoggedIn => _authController.isLoggedIn;

  var currentPage = 0.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index % bankCards.length;
  }

  final List<String> cardActionIcons = [
    'assets/icons/transfer.svg',
    'assets/icons/payment.svg',
    'assets/icons/qr.svg',
    'assets/icons/history.svg',
  ];

  final List<BankCard> bankCards = [
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '4829 •••• •••• 3078',
      tengeBalance: formatCurrency(0.00, 'KZT', currentLocale.toString()),
      usdBalance: formatCurrency(0.00, 'USD', currentLocale.toString()),
      euroBalance: formatCurrency(0.00, 'EUR', currentLocale.toString()),
      color: 'primary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '9686 •••• •••• 2197',
      tengeBalance: formatCurrency(0.00, 'KZT', currentLocale.toString()),
      usdBalance: formatCurrency(0.00, 'USD', currentLocale.toString()),
      euroBalance: formatCurrency(0.00, 'EUR', currentLocale.toString()),
      color: 'tertiary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '4386 •••• •••• 8921',
      tengeBalance: formatCurrency(0.00, 'KZT', currentLocale.toString()),
      usdBalance: formatCurrency(0.00, 'USD', currentLocale.toString()),
      euroBalance: formatCurrency(0.00, 'EUR', currentLocale.toString()),
      color: 'secondary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '5829 •••• •••• 8764',
      tengeBalance: formatCurrency(0.00, 'KZT', currentLocale.toString()),
      usdBalance: formatCurrency(0.00, 'USD', currentLocale.toString()),
      euroBalance: formatCurrency(0.00, 'EUR', currentLocale.toString()),
      color: 'gray',
    )
  ];
  final List<CardPromoItem> promoItems = [
    CardPromoItem(
      banner: 'assets/images/digital_bonus.svg',
      title: 'Цифровая карта бонус',
      info: 'Одна карта - тысяча возможностей',
    ),
    CardPromoItem(
      banner: 'assets/images/credit_card.svg',
      title: 'Кредитная карта',
      info: 'Беспроцентный период до 55 дней',
    ),
    CardPromoItem(
      banner: 'assets/images/debit_card.svg',
      title: 'Дебетовая карта',
      info: 'Кэшбэк до 5% на все покупки',
    ),
  ];
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
  final AccountsController _controller = Get.put(AccountsController());

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
                                          _controller.bankCards.length,
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
                            scrollDirection: Axis.vertical,
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
