//transfer by phone
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CardModel {
  final String icon;
  final String title;
  final String balance;
  final String cardNumber;
  final List<String> altBalances;

  CardModel({
    required this.icon,
    required this.title,
    required this.balance,
    required this.cardNumber,
    required this.altBalances,
  });
}

class PhoneTransferController extends GetxController {
  final RxList<CardModel> cards = <CardModel>[
    CardModel(
      icon: 'assets/icons/card.svg',
      title: 'Дебетовая карта',
      balance: '458 932.00 ₸',
      cardNumber: '**** 1234',
      altBalances: ['1 254.32 \$', '1 023.45 €'],
    ),
    CardModel(
      icon: 'assets/icons/card.svg',
      title: 'Кредитная карта',
      balance: '125 450.00 ₸',
      cardNumber: '**** 5678',
      altBalances: ['458.75 \$'],
    ),
  ].obs;

  final Rx<CardModel?> selectedCard = Rx<CardModel?>(null);
  final RxString phoneNumber = ''.obs;
  final RxString amount = ''.obs;
  final RxBool isCardDropdownExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedCard.value = cards.first;
  }

  String formatPhoneNumber(String value) {
    if (value.isEmpty) return '';
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length <= 3) return value;
    if (value.length <= 6) {
      return '(${value.substring(0, 3)}) ${value.substring(3)}';
    }
    if (value.length <= 10) {
      return '(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6)}';
    }
    return '(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6, 8)}-${value.substring(8, 10)}';
  }

  String formatAmount(String value) {
    if (value.isEmpty) return '';
    value = value.replaceAll(RegExp(r'\D'), '');
    final number = int.tryParse(value) ?? 0;
    return '${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₸';
  }
}

class PhoneTransferScreen extends StatelessWidget {
  final PhoneTransferController controller = Get.put(PhoneTransferController());

  PhoneTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Перевод'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Selection
              _buildCardSelector(theme),
              SizedBox(height: 16),

              // Phone Number Input
              _buildPhoneInput(theme),
              SizedBox(height: 16),

              // Amount Input
              _buildAmountInput(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSelector(ThemeData theme) {
    return Obx(() => Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => controller.isCardDropdownExpanded.toggle(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Откуда',
                        style: theme.textTheme.titleMedium,
                      ),
                      Spacer(),
                      Icon(
                        controller.isCardDropdownExpanded.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isCardDropdownExpanded.value)
                ...controller.cards.map((card) => _buildCardItem(card, theme)),
              if (!controller.isCardDropdownExpanded.value &&
                  controller.selectedCard.value != null)
                _buildCardItem(controller.selectedCard.value!, theme,
                    isSelectable: false),
            ],
          ),
        ));
  }

  Widget _buildCardItem(CardModel card, ThemeData theme,
      {bool isSelectable = true}) {
    return InkWell(
      onTap: isSelectable
          ? () {
              controller.selectedCard.value = card;
              controller.isCardDropdownExpanded.value = false;
            }
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                card.icon,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: theme.textTheme.titleSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    card.cardNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              card.balance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '🇰🇿',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+7',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: '(000) 000-00-00',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  controller.phoneNumber.value =
                      controller.formatPhoneNumber(value);
                },
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/contacts.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сумма',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0 ₸',
                border: InputBorder.none,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                controller.amount.value = controller.formatAmount(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
