import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/accounts_controller.dart';
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
  final AccountsController accountsController = Get.find<AccountsController>();

  // final RxList<CardModel> cards = <CardModel>[].obs;

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final RxString phoneNumber = ''.obs;
  final RxString formattedPhoneNumber = ''.obs;
  final RxString amount = ''.obs;
  String previousNumber = '';
  final RxString formattedAmount = ''.obs;
  final RxBool isAccountDropdownExpanded = false.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  int _previousPhoneValue = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeSelectedAccount();
    amountController.text = '0';
    updateAmount('0');
  }

  void _initializeSelectedAccount() {
    if (accountsController.accounts.isNotEmpty) {
      selectedAccount.value = accountsController.accounts.first;
    }
  }

  void refreshCards() {
    accountsController
        .fetchAccounts()
        .then((_) => _initializeSelectedAccount());
  }

  void updatePhoneNumber(String value) {
    int cursorPosition = phoneController.value.selection.start;

    String oldDigits =
        _previousPhoneValue.toString().replaceAll(RegExp(r'\D'), '');
    String newDigits = value.replaceAll(RegExp(r'\D'), '');
    bool isDeleting = newDigits.length < oldDigits.length;

    String formatted = '';
    if (newDigits.isNotEmpty) {
      if (newDigits.length <= 3) {
        formatted = '($newDigits';
      } else if (newDigits.length <= 6) {
        formatted = '(${newDigits.substring(0, 3)}) ${newDigits.substring(3)}';
      } else {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6, min(10, newDigits.length))}';
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
    if (formatted.length == 14) {
      accountsController.getAccountByPhone(formatted);
    } else {
      accountsController.recipientAccount.value = null;
    }
    print(formatted.length);
    print(formatted);
    _previousPhoneValue = int.tryParse(formatted) ?? 0;
  }

  void updateAmount(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    const int maxTransferAmount = 2000000;

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
    final botomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  _buildHeader(context),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                        } on TimeoutException {
                          print('Refresh operation timed out');
                        } catch (e) {
                          print('Error during refresh: $e');
                        }
                        return Future.value();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardSelector(theme),
                            SizedBox(height: size.height * 0.02),
                            _buildPhoneInput(theme),
                            SizedBox(height: size.height * 0.02),
                            _buildAmountInput(theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    final amount = controller.amount.value.isEmpty
                        ? 0
                        : int.parse(controller.amount.value);

                    final formattedAmount = amount.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]} ',
                        );

                    return AnimatedPadding(
                        duration: const Duration(milliseconds: 50),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(bottom: botomInset),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.selectedAccount.value == null) {
                              Get.snackbar('Error', 'Please select a card');
                              return;
                            }

                            String phoneNumber = controller.phoneController.text
                                .replaceAll(RegExp(r'\D'), '');
                            if (phoneNumber.isEmpty) {
                              Get.snackbar(
                                  'Error', 'Please enter phone number');
                              return;
                            }

                            if (controller.amount.value.isEmpty ||
                                controller.amount.value == '0') {
                              Get.snackbar('Error', 'Please enter amount');
                              return;
                            }

                            // First lookup recipient account by phone
                            if (controller.accountsController.recipientAccount
                                    .value ==
                                null) {
                              Get.snackbar(
                                  'Error', 'Recipient account not found');
                              return;
                            }
                            print(
                                'From account: ${controller.selectedAccount.value!.accountNumber}');
                            print(
                                'To account: ${controller.accountsController.recipientAccount.value!.accountNumber}');
                            print('Amount: ${controller.amount.value}');
                            print(
                                'Currency: ${controller.selectedAccount.value!.currency}');

                            // Proceed with transfer using found account
                            final success = await controller.accountsController
                                .createTransaction(
                                    controller
                                        .selectedAccount.value!.accountNumber,
                                    controller.accountsController
                                        .recipientAccount.value!.accountNumber,
                                    double.parse(controller.amount.value),
                                    controller.selectedAccount.value!.currency);

                            if (success) {
                              Get.snackbar('Success', 'Transfer completed');
                              controller.refreshCards();
                            } else {
                              Get.snackbar('Error', 'Transfer failed');
                            }
                          },
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
                        ));
                  }),
                  SizedBox(
                    height: size.height * 0.015,
                  ),
                ]))));
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                'По номеру телефона',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelector(ThemeData theme) {
    return Obx(() {
      if (controller.accountsController.accounts.isEmpty) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'У вас нет доступных счетов',
              style: theme.textTheme.titleMedium,
            ),
          ),
        );
      }
      return AnimatedCardDropdown(
        accounts: controller.accountsController.accounts,
        selectedAccount: controller.selectedAccount.value,
        isExpanded: controller.isAccountDropdownExpanded.value,
        onAccountSelected: (account) {
          controller.selectedAccount.value = account;
          controller.isAccountDropdownExpanded.value = false;
        },
        onToggle: () => controller.isAccountDropdownExpanded.toggle(),
      );
    });
  }

  Widget _buildPhoneInput(ThemeData theme) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
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
                  hintText: '(000) 000-0000',
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
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12),
          child: Obx(() => Text(
                controller
                        .accountsController.recipientAccount.value?.fullName ??
                    'Получатель не найден',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurface),
              )),
        )
      ]),
    ));
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
