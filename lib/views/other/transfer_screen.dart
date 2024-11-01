import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../shared/animated_dropdown.dart';

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

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  final Rx<CardModel?> selectedCard = Rx<CardModel?>(null);
  final RxString phoneNumber = ''.obs;
  final RxString formattedPhoneNumber = ''.obs;
  final RxString amount = ''.obs;
  String previousNumber = '';
  final RxString formattedAmount = ''.obs;
  final RxBool isCardDropdownExpanded = false.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  int _previousPhoneValue = 0;

  @override
  void onInit() {
    super.onInit();
    selectedCard.value = cards.first;
    amountController.text = '0';
    updateAmount('0');
  }

  void updatePhoneNumber(String value) {
    int cursorPosition = phoneController.selection.start;

    String oldDigits =
        _previousPhoneValue.toString().replaceAll(RegExp(r'\D'), '');
    String newDigits = value.replaceAll(RegExp(r'\D'), '');
    bool isDeleting = newDigits.length < oldDigits.length;

    String formatted = '';
    if (newDigits.isNotEmpty) {
      if (newDigits.length <= 3) {
        formatted = '($newDigits';
      }
      else if (newDigits.length <= 6) {
        formatted = '(${newDigits.substring(0, 3)}) ${newDigits.substring(3)}';
      }
      else if (newDigits.length <= 8) {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6)}';
      }
      else {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6, 8)}-${newDigits.substring(8, min(10, newDigits.length))}';
      }
    }

    int newCursorPosition;
    if (isDeleting) {
      newCursorPosition = max(0, min(cursorPosition - 1, formatted.length));
    } else {
      newCursorPosition = formatted.length;
    }

    phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _previousPhoneValue = int.tryParse(formatted) ?? 0;
  }

  void updateAmount(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    const int maxTransferAmount = 999999999;

    if (digitsOnly.isEmpty) {
      amount.value = '';
      formattedAmount.value = '';
      amountController.value = TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
      return;
    }

    int number = int.tryParse(digitsOnly) ?? 0;

    if (number > maxTransferAmount) {
      number = int.parse(previousNumber);
      String formatted = previousNumber.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
      final oldCursor = amountController.selection.start;
      final oldTextLength = amountController.text.length;
      final distanceFromEnd = oldTextLength - oldCursor;

      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length - distanceFromEnd,
        ),
      );
      return;
    }

    String formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );

    amount.value = digitsOnly;
    formattedAmount.value = digitsOnly;
    previousNumber = digitsOnly;

    final oldCursor = amountController.selection.start;
    final oldTextLength = amountController.text.length;
    final distanceFromEnd = oldTextLength - oldCursor;

    amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length - distanceFromEnd,
      ),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }
}

class PhoneTransferScreen extends StatelessWidget {
  final PhoneTransferController controller = Get.put(PhoneTransferController());

  PhoneTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              _buildCardSelector(theme),
              SizedBox(height: size.height * 0.02),
              _buildPhoneInput(theme),
              SizedBox(height: size.height * 0.02),
              _buildAmountInput(theme),
              SizedBox(height: size.height * 0.02),
              Obx(() {
                final amount = controller.amount.value.isEmpty
                    ? 0
                    : int.parse(controller.amount.value);

                final formattedAmount = amount.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]} ',
                    );

                return ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('Перевести $formattedAmount ₸',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                      )),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSelector(ThemeData theme) {
    return Obx(() => AnimatedCardDropdown(
          cards: controller.cards,
          selectedCard: controller.selectedCard.value,
          isExpanded: controller.isCardDropdownExpanded.value,
          onCardSelected: (card) {
            controller.selectedCard.value = card;
            controller.isCardDropdownExpanded.value = false;
          },
          onToggle: () => controller.isCardDropdownExpanded.toggle(),
        ));
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
                controller: controller.phoneController,
                keyboardType: TextInputType.number,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: '(000) 000-00-00',
                  border: InputBorder.none,
                ),
                onChanged: controller.updatePhoneNumber,
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/user.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () async {
                final permission = await Permission.contacts.request();
                if (permission.isGranted) {
                  Contact? contact =
                      await controller._contactPicker.selectContact();
                  if (contact != null &&
                      contact.phoneNumbers != null &&
                      contact.phoneNumbers!.isNotEmpty) {
                    String phoneNumber = contact.phoneNumbers!
                        .toString()
                        .replaceAll(RegExp(r'\D'), '')
                        .substring(1);

                    controller.phoneController.text = phoneNumber;
                    controller.updatePhoneNumber(phoneNumber);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        controller.amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.amountController.text.length),
        );
        controller.amountFocusNode.requestFocus();
      },
      child: Card(
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
              Row(
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      focusNode: controller.amountFocusNode,
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        isDense: true,
                        suffixText: ' ₸',
                        suffixStyle: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: controller.updateAmount,
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
