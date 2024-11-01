import 'package:bank_app/utils/themes/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
  late PageController pageController;
  var currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(
      viewportFraction: 0.85,
      initialPage: bankCards.length * 500,
    );
  }

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

  final String defaultName = 'Фамилия Имя';

  final List<BankCard> bankCards = [
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '4829 •••• •••• 3078',
      tengeBalance: '0.00 ₸',
      usdBalance: '0.00 \$',
      euroBalance: '0.00 €',
      color: 'primary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '9686 •••• •••• 2197',
      tengeBalance: '0.00 ₸',
      usdBalance: '0.00 \$',
      euroBalance: '0.00 €',
      color: 'tertiary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '4386 •••• •••• 8921',
      tengeBalance: '0.00 ₸',
      usdBalance: '0.00 \$',
      euroBalance: '0.00 €',
      color: 'secondary',
    ),
    BankCard(
      name: 'Фамилия Имя',
      type: 'VISA Мультивалютная',
      number: '5829 •••• •••• 8764',
      tengeBalance: '0.00 ₸',
      usdBalance: '0.00 \$',
      euroBalance: '0.00 €',
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
  final AccountsController controller = Get.put(AccountsController());

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
                            Obx(() => Row(
                                  children: List.generate(
                                    controller.bankCards.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: controller.currentPage.value ==
                                                index
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.primary
                                                .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: controller.pageController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: controller.onPageChanged,
                            itemBuilder: (context, index) {
                              final card = controller.bankCards[
                                  index % controller.bankCards.length];
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: _buildBankCard(
                                  context: context,
                                  card: card,
                                ),
                              );
                            },
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
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorFg,
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -140,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorFg,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  card.type,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  card.number,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Monospace',
                  ),
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
                                  card.tengeBalance ?? '0.00 ₸',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Container(),
                          card.usdBalance != null
                              ? Text(
                                  card.usdBalance ?? '0.00 \$',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Container(),
                          card.euroBalance != null
                              ? Text(
                                  card.euroBalance ?? '0.00 €',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
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
