//accounts_screen.dart // page 4
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AccountsController extends GetxController {
  final List<String> cardActionIcons = [
    'assets/icons/transfer.svg',
    'assets/icons/payment.svg',
    'assets/icons/qr.svg',
    'assets/icons/history.svg',
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
                          'Карты',
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
                        child: Text(
                          'Мои карты',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _buildCardItem(
                        context: context,
                        icon: 'assets/icons/card.svg',
                        title: 'Дебетовая карта',
                        balance: '458 932.00 ₸',
                        cardNumber: '**** 1234',
                        altBalances: ['1 254.32 \$', '1 023.45 €'],
                        actionIcons: controller.cardActionIcons,
                      ),
                      Divider(height: 1),
                      _buildCardItem(
                        context: context,
                        icon: 'assets/icons/card.svg',
                        title: 'Кредитная карта',
                        balance: '125 450.00 ₸',
                        cardNumber: '**** 5678',
                        altBalances: ['458.75 \$'],
                        actionIcons: controller.cardActionIcons,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Open Card Section
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Открыть карту',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      ...controller.promoItems.map((item) => _buildPromoItem(
                            context: context,
                            item: item,
                          )),
                    ],
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
    required String balance,
    required String cardNumber,
    required List<String> altBalances,
    required List<String> actionIcons,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                balance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                cardNumber,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  altBalances.join(' • '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actionIcons
                .map((iconPath) => SvgPicture.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

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
