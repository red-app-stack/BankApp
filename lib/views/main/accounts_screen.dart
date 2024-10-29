//accounts_screen.dart // page 4
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
      initialPage: bankCards.length * 500, // Start from middle of large number
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

  final List<BankCard> bankCards = [
    BankCard(
      name: 'Александр Петров',
      type: 'VISA Мультивалютная',
      number: '4829 •••• •••• 3078',
      tengeBalance: '458 932.00 ₸',
      usdBalance: '1 254.32 \$',
      euroBalance: '1 023.45 €',
      color: 'primary',
    ),
    BankCard(
      name: 'Александр Петров',
      type: 'VISA Мультивалютная',
      number: '9686 •••• •••• 2197',
      tengeBalance: '285 109.00 ₸',
      usdBalance: '581.34 \$',
      euroBalance: '537.43 €',
      color: 'tertiary',
    ),
    BankCard(
      name: 'Александр Петров',
      type: 'VISA Мультивалютная',
      number: '4386 •••• •••• 8921',
      tengeBalance: '152 846.00 ₸',
      usdBalance: '311.65 \$',
      euroBalance: '288.11 €',
      color: 'secondary',
    ),
    BankCard(
      name: 'Александр Петров',
      type: 'VISA Мультивалютная',
      number: '5829 •••• •••• 8764',
      tengeBalance: '2 846.00 ₸',
      usdBalance: '5.80 \$',
      euroBalance: '5.36 €',
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
                SizedBox(height: 16),

                // My Cards Section
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
                            Spacer(),
                            // Optional: Add page indicator
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
                      SizedBox(height: 12),
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
                SizedBox(height: 16),

                // Open Credit Section
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
                      // ...controller.promoItems.map((item) => _buildPromoItem(
                      //       context: context,
                      //       item: item,
                      //     )),
                    ],
                  ),
                ),
                // Open Deposit Section
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
                      // ...controller.promoItems.map((item) => _buildPromoItem(
                      //       context: context,
                      //       item: item,
                      //     )),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/illustration_accounts.svg',
                    width: MediaQuery.of(context).size.width * 0.85,
                  ),
                ),
                SizedBox(height: 32),
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
    // final Color colorFg =
    return Container(
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // Add this line to handle clipping
      child: Stack(
        children: [
          // Background circles
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

          // Card content
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
                Spacer(),
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
                Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Balances
                    Expanded(
                      child: Wrap(
                        spacing: 10, // Horizontal spacing between items
                        runSpacing: 8, // Vertical spacing between wrapped lines
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          card.tengeBalance != null
                              ? Text(
                                  card.tengeBalance!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Container(),
                          card.usdBalance != null
                              ? Text(
                                  card.usdBalance!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Container(),
                          card.euroBalance != null
                              ? Text(
                                  card.euroBalance!,
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

  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: theme.colorScheme.surfaceContainerHighest,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: SvgPicture.asset(
  //                 icon,
  //                 width: 24,
  //                 height: 24,
  //                 colorFilter: ColorFilter.mode(
  //                   theme.colorScheme.primary,
  //                   BlendMode.srcIn,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 title,
  //                 style: theme.textTheme.titleSmall,
  //               ),
  //             ),
  //             Text(
  //               balance,
  //               style: theme.textTheme.titleMedium?.copyWith(
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Text(
  //               cardNumber,
  //               style: theme.textTheme.bodyMedium?.copyWith(
  //                 color: theme.colorScheme.onSurfaceVariant,
  //               ),
  //             ),
  //             Expanded(
  //               child: Text(
  //                 altBalances.join(' • '),
  //                 style: theme.textTheme.bodyMedium?.copyWith(
  //                   color: theme.colorScheme.onSurfaceVariant,
  //                 ),
  //                 textAlign: TextAlign.right,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 12),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: actionIcons
  //               .map((iconPath) => SvgPicture.asset(
  //                     iconPath,
  //                     width: 24,
  //                     height: 24,
  //                     colorFilter: ColorFilter.mode(
  //                       theme.colorScheme.primary,
  //                       BlendMode.srcIn,
  //                     ),
  //                   ))
  //               .toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPromoItem({
    required BuildContext context,
    required CardPromoItem item,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SvgPicture.asset(
          item.banner,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          item.info,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {},
                    child: Text('Открыть'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Узнать подробнее',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
