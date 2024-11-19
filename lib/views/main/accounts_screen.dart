import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bank_app/utils/themes/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../controllers/accounts_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import '../shared/formatters.dart';

class BankCard {
  final String name;
  final String cardType;
  final String type;
  final String number;
  final String? tengeBalance;
  final String? usdBalance;
  final String? euroBalance;
  final String color;
  final String expiryDate = "12/25"; // Placeholder
  final String cvv = "497"; // Placeholder

  BankCard({
    required this.name,
    required this.cardType,
    required this.type,
    required this.number,
    required this.tengeBalance,
    required this.usdBalance,
    required this.euroBalance,
    required this.color,
    // required this.expiryDate,
    // required this.cvv,
  });
}

class AccountsScreenController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final AccountsController accountsController = Get.find<AccountsController>();
  final AuthController _authController = Get.find<AuthController>();
  final RxMap<String, bool> cardFlipStates = <String, bool>{}.obs;
  final RxString visibleCard = ''.obs;

  bool get isLoggedIn => _authController.isLoggedIn;
  var currentDebitCard = 0.obs;
  var currentDepositCard = 0.obs;
  var currentCreditCard = 0.obs;
  final RxList<BankCard> debits = <BankCard>[].obs;
  final RxList<BankCard> deposits = <BankCard>[].obs;
  final RxList<BankCard> credits = <BankCard>[].obs;
  @override
  void onInit() {
    super.onInit();
    ever(accountsController.accounts, (_) => updateBankCards());
  }

  void fetchAndUpdateCards() async {
    await accountsController.fetchAccounts();
  }

  void toggleCardFlip(String cardNumber) {
    cardFlipStates[cardNumber] = !(cardFlipStates[cardNumber] ?? false);
  }

  void updateBankCards() {
    print(
        'Updating bank cards with ${accountsController.accounts.length} accounts');
    debits.clear();
    deposits.clear();
    credits.clear();

    for (AccountModel account in accountsController.accounts) {
      final bankCard = BankCard(
        name: userService.currentUser?.fullName ?? '',
        type: 'VISA ${account.accountType}',
        cardType: account.accountType,
        number: account.accountNumber,
        tengeBalance: account.currency == 'KZT'
            ? formatCurrency(account.balance, 'KZT', currentLocale.toString())
            : null,
        usdBalance: account.currency == 'USD'
            ? formatCurrency(account.balance, 'USD', currentLocale.toString())
            : null,
        euroBalance: account.currency == 'EUR'
            ? formatCurrency(account.balance, 'EUR', currentLocale.toString())
            : null,
        color: _getCardColor(account.accountType),
      );

      switch (account.accountType.toLowerCase()) {
        case 'card':
          debits.add(bankCard);
          if (visibleCard.value.isEmpty) {
            visibleCard.value = bankCard.number;
          }
          break;
        case 'deposit':
          deposits.add(bankCard);
          break;
        case 'credit':
          credits.add(bankCard);
          break;
      }
    }
  }

  String _getCardColor(String accountType) {
    print(accountType);
    switch (accountType.toLowerCase()) {
      case 'credit':
        return 'tertiary';
      case 'deposit':
        return 'yellow';
      case 'card':
        return 'primary';
      default:
        return 'yellow';
    }
  }

  void onPageChanged(int index, String type) {
    switch (type) {
      case 'debit':
        currentDebitCard.value = index % debits.length;
        break;
      case 'deposit':
        currentDepositCard.value = index % deposits.length;
        break;
      case 'credit':
        currentCreditCard.value = index % credits.length;
        break;
    }
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _controller.fetchAndUpdateCards();
          const timeout = Duration(seconds: 10);
          try {
            await Future.any([
              _controller.debits.stream.timeout(timeout).first,
              _controller.credits.stream.timeout(timeout).first,
              _controller.deposits.stream.timeout(timeout).first,
            ]).timeout(timeout);

            await Future.delayed(const Duration(milliseconds: 300));
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
                Obx(() => _buildCardSection(
                      context: context,
                      cards: _controller.debits,
                      title: 'Дебетовые карты',
                      size: size,
                      type: 'debit',
                      onCardLongPress: () {},
                      child: _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Открыть новую карту',
                          description: null,
                          onTap: () {
                            Get.toNamed('/createAccount', arguments: 'card');
                          }),
                    )),
                SizedBox(height: size.height * 0.02),
                Obx(() => _buildCardSection(
                      context: context,
                      cards: _controller.credits,
                      title: 'Кредиты',
                      size: size,
                      type: 'credit',
                      child: _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Оформить кредит наличными',
                          description: 'Онлайн до 7 000 000 тенге',
                          onTap: () {
                            Get.toNamed('/createAccount', arguments: 'credit');
                          }),
                    )),
                SizedBox(height: size.height * 0.02),
                Obx(() => _buildCardSection(
                      context: context,
                      cards: _controller.deposits,
                      title: 'Депозиты',
                      size: size,
                      type: 'deposit',
                      child: _buildCardItem(
                          context: context,
                          icon: 'assets/icons/ic_add.svg',
                          title: 'Открыть депозит',
                          description: 'На выгодных условиях',
                          onTap: () {
                            Get.toNamed('/createAccount', arguments: 'deposit');
                          }),
                    )),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Center(
                  child: SizedBox(
                    height: size.height * 0.3,
                    child: (theme.brightness == Brightness.dark)
                        ? Container()
                        : SvgPicture.asset(
                            'assets/icons/illustration_accounts.svg',
                            fit: BoxFit.contain,
                          ),
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
    ));
  }

  Widget _buildBankCard({
    required BuildContext context,
    required BankCard card,
    Function()? onCardTap,
    Function()? onCardLongPress,
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
                : card.color == 'yellow'
                    ? theme.extension<CustomColors>()!.yellowCardBg!
                    : card.color == 'gold'
                        ? theme.extension<CustomColors>()!.goldCardBg!
                        : card.color == 'purple'
                            ? theme.extension<CustomColors>()!.purpleCardBg!
                            : card.color == 'red'
                                ? theme.extension<CustomColors>()!.redCardBg!
                                : theme.extension<CustomColors>()!.grayCardBg!;

    final Color colorFg = card.color == 'primary'
        ? theme.extension<CustomColors>()!.primaryCardFg!
        : card.color == 'secondary'
            ? theme.extension<CustomColors>()!.secondaryCardFg!
            : card.color == 'tertiary'
                ? theme.extension<CustomColors>()!.tertiaryCardFg!
                : card.color == 'yellow'
                    ? theme.extension<CustomColors>()!.yellowCardFg!
                    : card.color == 'gold'
                        ? theme.extension<CustomColors>()!.goldCardFg!
                        : card.color == 'purple'
                            ? theme.extension<CustomColors>()!.purpleCardFg!
                            : card.color == 'red'
                                ? theme.extension<CustomColors>()!.redCardFg!
                                : theme.extension<CustomColors>()!.grayCardFg!;
    return GestureDetector(
      onTap: () {
        if (_controller.visibleCard.value == card.number &&
            card.cardType == 'card') {
          _controller.toggleCardFlip(card.number);
        }
      },
      onLongPress: () {
        if (card.cardType == 'card') {
          _controller.toggleCardFlip(card.number);
        }
      },
      child: Obx(() => TweenAnimationBuilder(
            key: ValueKey(card.number),
            tween: Tween<double>(
              begin: 0,
              end: _controller.cardFlipStates[card.number] ?? false ? 180 : 0,
            ),
            duration: const Duration(milliseconds: 400),
            builder: (context, double value, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value * pi / 180),
                child: value < 90
                    ? _buildCardFront(theme, card, width, colorBg, colorFg)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _buildCardBack(
                            theme, card, width, colorBg, colorFg),
                      ),
              );
            },
          )),
    );
  }

  Widget _buildCardFront(
    ThemeData theme,
    BankCard card,
    double width,
    Color colorBg,
    Color colorFg,
  ) {
    return Container(
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
              Positioned(
                  bottom: 28,
                  right: 28,
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(
                        "assets/icons/visa.svg",
                        width: 50,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ))),
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
                    const Spacer(flex: 5),
                    Text(
                      card.type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      censorCardNumber(card.number),
                      style: theme.textTheme.titleLarge?.copyWith(
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
                              Text(
                                card.tengeBalance ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                card.usdBalance ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                card.euroBalance ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCardBack(
    ThemeData theme,
    BankCard card,
    double width,
    Color colorBg,
    Color colorFg,
  ) {
    RxString cvv = 'CVV'.obs;

    return Container(
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
              Positioned(
                  bottom: 28,
                  right: 28,
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(
                        "assets/icons/visa.svg",
                        width: 50,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ))),
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
                    const Spacer(flex: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            formatCardNumber(card.number),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.white),
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: card.number)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  card.expiryDate,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, color: Colors.white),
                                  onPressed: () => Clipboard.setData(
                                    ClipboardData(text: card.expiryDate),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                cvv.value =
                                    cvv.value == 'CVV' ? card.cvv : 'CVV';
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Obx(() => Text(
                                        cvv.value,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      )),
                                ),
                              ),
                            )),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  bool _getCurrentPage(String type, int index) {
    switch (type) {
      case 'debit':
        return _controller.currentDebitCard.value == index;
      case 'credit':
        return _controller.currentCreditCard.value == index;
      case 'deposit':
        return _controller.currentDepositCard.value == index;
      default:
        return false;
    }
  }

// Add this helper method to the AccountsScreen class
  Widget _buildCardSection(
      {required BuildContext context,
      required List<BankCard> cards,
      required String title,
      required Size size,
      required String type,
      Function()? onCardTap,
      Function()? onCardLongPress,
      Widget? child}) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    cards.length > 1
                        ? Obx(() => SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  cards.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    width:
                                        _getCurrentPage(type, index) ? 16 : 8,
                                    height: 8,
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape
                                          .circle, // Keep circle shape for inactive
                                      color: _getCurrentPage(type, index)
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
              cards.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: size.width > size.height
                            ? size.height * 0.6
                            : size.width * 0.85 / 1.586 +
                                20, // Added extra height buffer
                        child: Swiper(
                          physics: cards.isEmpty
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          loop: false,
                          allowImplicitScrolling: cards.isNotEmpty,
                          itemCount: cards.length,
                          onIndexChanged: (index) {
                            _controller.onPageChanged(index, type);
                            if (type == 'debit') {
                              _controller.visibleCard.value =
                                  cards[index].number;
                            }
                            for (BankCard card in cards) {
                              if (_controller.cardFlipStates[card.number] ==
                                  true) {
                                _controller.toggleCardFlip(card.number);
                              }
                            }
                          },
                          itemBuilder: (context, index) {
                            final card = cards[index];
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
                                      child: TweenAnimationBuilder<double>(
                                        duration:
                                            const Duration(milliseconds: 100),
                                        tween: Tween<double>(
                                          begin: 0.3,
                                          end: _getCurrentPage(type, index)
                                              ? 0
                                              : 5,
                                        ),
                                        builder: (context, value, child) {
                                          return ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: value,
                                              sigmaY: value,
                                            ),
                                            child: _buildBankCard(
                                              context: context,
                                              card: card,
                                              onCardTap: onCardTap,
                                              onCardLongPress: onCardLongPress,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          layout: SwiperLayout.TINDER,
                          itemWidth: size.width * 0.85,
                          itemHeight: size.width * 0.85 / 1.586,
                          scale: 0.5,
                          viewportFraction: 0.5,
                          curve: Curves.easeInOut,
                          duration: 400,
                        ),
                      ),
                    )
                  : Container(),
              cards.isNotEmpty
                  ? SizedBox(height: size.height * 0.02)
                  : Container(),
              (child != null && cards.isNotEmpty)
                  ? Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.secondaryContainer)
                  : Container(),
              child ?? Container()
            ],
          ),
        ),
      ],
    );
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
