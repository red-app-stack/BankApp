import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/accounts_controller.dart';
import '../shared/animated_dropdown.dart';
import '../shared/formatters.dart';

class ConvertController extends GetxController {
  final AccountsController accountsController = Get.find<AccountsController>();

  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final RxString amount = ''.obs;
  String previousNumber = '';
  Transaction? transaction;
  final RxString formattedAmount = ''.obs;
  final RxBool isAccountDropdownExpanded = false.obs;
  final Rx<AccountModel?> selectedDestinationAccount = Rx<AccountModel?>(null);
  final RxBool isDestinationDropdownExpanded = false.obs;

  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _initializeSelectedAccount();
    amountController.text = '0';
    updateAmount('0');
    transaction = Get.arguments;
    if (transaction != null) {
      print(transaction?.amount.toString());
      updateAmount(transaction?.amount.toString() ?? '');
      // phoneNumber.value = transaction?.toUserPhone ?? '';
    }
  }

  void _initializeSelectedAccount() {
    if (accountsController.accounts.isNotEmpty) {
      final cards = accountsController.accounts
          .where((account) => account.accountType == 'card')
          .toList()
        ..sort((a, b) => b.balance.compareTo(a.balance));

      selectedAccount.value = cards.isNotEmpty ? cards.first : null;
      selectedDestinationAccount.value = cards.isNotEmpty ? cards[1] : null;
    }
  }

  void refreshCards() {
    accountsController
        .fetchAccounts()
        .then((_) => _initializeSelectedAccount());
  }

  void updateAmount(String value) {
    const int maxTransferAmount = 2000000;
    String normalizedValue = value.replaceAll('.', ',');

    List<String> parts = normalizedValue.split(',');
    String integerPart = parts[0].replaceAll(RegExp(r'\D'), '');
    String decimalPart =
        parts.length > 1 ? parts[1].replaceAll(RegExp(r'\D'), '') : '';

    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    if (integerPart.isEmpty) {
      amount.value = '';
      formattedAmount.value = '0';
      amountController.value = TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
      return;
    }

    int number = int.tryParse(integerPart) ?? 0;

    if (number > maxTransferAmount) {
      print(number);
      number = int.parse(previousNumber.split(',')[0]);
      String formatted = _formatAmount(number);

      if (normalizedValue.contains(',')) {
        formatted += ',$decimalPart';
      }

      _updateControllerValue(formatted);
      return;
    }

    String formatted = _formatAmount(number);
    if (normalizedValue.contains(',')) {
      formatted += ',$decimalPart';
    }

    amount.value =
        number.toString() + (decimalPart.isNotEmpty ? ',$decimalPart' : '');
    formattedAmount.value = formatted;
    previousNumber = amount.value;

    _updateControllerValue(formatted);
  }

  String _formatAmount(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  void _updateControllerValue(String formatted) {
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
    amountController.dispose();
    amountFocusNode.dispose();
    accountsController.recipientAccount.value = null;
    super.onClose();
  }
}

class ConvertScreen extends StatelessWidget {
  final ConvertController controller = Get.put(ConvertController());

  ConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                            buildCardSelector(theme),
                            SizedBox(height: size.height * 0.02),
                            buildDestinationCardSelector(theme),
                            SizedBox(height: size.height * 0.02),
                            _buildAmountInput(theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    double amount = controller.amount.value.isEmpty
                        ? 0
                        : double.parse(
                            controller.amount.value.replaceAll(',', '.'));
                    return AnimatedPadding(
                        duration: const Duration(milliseconds: 50),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.selectedAccount.value == null) {
                              Get.snackbar(
                                  'Ошибка', 'Пожалуйста, выберите карту');
                              return;
                            }

                            if (controller.amount.value.isEmpty) {
                              Get.snackbar(
                                  'Ошибка', 'Пожалуйста, введите сумму');
                              return;
                            }

                            // First lookup recipient account by phone
                            if (controller.selectedDestinationAccount.value ==
                                null) {
                              Get.snackbar('Ошибка', 'Получатель не найден');
                              return;
                            }

                            // Proceed with transfer using found account
                            final transaction = await controller
                                .accountsController
                                .createTransaction(
                                    controller
                                        .selectedAccount.value!.accountNumber,
                                    controller.selectedDestinationAccount.value!
                                        .accountNumber,
                                    amount,
                                    controller.selectedAccount.value!.currency,
                                    'internal_transfer');

                            if (transaction != null &&
                                transaction.status == 'completed') {
                              Get.toNamed('/transferDetails',
                                  arguments: transaction);
                              Get.snackbar('Успех', 'Перевод успешно выполнен');
                              controller.refreshCards();
                            } else {
                              Get.snackbar('Ошибка', 'Перевод не выполнен');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          child: Text(
                              'Перевести ${controller.formattedAmount.value} ₸',
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
                'Конвертация',
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

  Widget buildCardSelector(ThemeData theme) {
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
      final availableAccounts = controller.accountsController.accounts
          .where((account) =>
              account != controller.selectedDestinationAccount.value)
          .toList();
      return AnimatedCardDropdown(
        accounts: availableAccounts,
        label: 'Откуда',
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

  Widget buildDestinationCardSelector(ThemeData theme) {
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

      // Filter out the selected source account
      final availableAccounts = controller.accountsController.accounts
          .where((account) => account != controller.selectedAccount.value)
          .toList();

      return AnimatedCardDropdown(
        accounts: availableAccounts,
        label: 'Куда',
        selectedAccount: controller.selectedDestinationAccount.value,
        isExpanded: controller.isDestinationDropdownExpanded.value,
        onAccountSelected: (account) {
          controller.selectedDestinationAccount.value = account;
          controller.isDestinationDropdownExpanded.value = false;
        },
        onToggle: () => controller.isDestinationDropdownExpanded.toggle(),
      );
    });
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Obx(() {
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
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          isDense: true,
                          suffixText:
                              ' ${getCurrencySymbol(controller.selectedAccount.value?.currency ?? 'KZT')}',
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
    });
  }
}
