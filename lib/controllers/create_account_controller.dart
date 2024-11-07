import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';
import 'accounts_controller.dart';

class CreateAccountController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final AccountsController accountsController = Get.find<AccountsController>();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isNotUsCitizen = false.obs;
  final accountType = 'card'.obs;
  final selectedCurrency = 'KZT'.obs;
  final selectedDocument = 'Удостоверение личности РК'.obs;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final monthlyIncomeController = TextEditingController();
  final additionalIncomeController = TextEditingController();
  final documentNumberController = TextEditingController();
  final documentExpiryController = TextEditingController();

  final List<String> documentTypes = [
    'Удостоверение личности РК',
    'Паспорт гражданина РК',
    'Вид на жительство иностранца в РК',
    'Удостоверение лица без гражданства, выданный РК',
    'Паспорт гражданина иностранного государства',
    'Удостоверение лица без гражданства',
    'Паспорт иностранца без гражданства',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _generateDocumentNumber();
  }

  void _initializeUserData() {
    final user = userService.currentUser;
    documentExpiryController.text = DateFormat('dd.MM.yyyy').format(
      DateTime.now().add(Duration(days: 182)),
    );
    if (user != null) {
      fullNameController.text = user.fullName;
      phoneController.text = user.phoneNumber;
    }
  }

  void _generateDocumentNumber() {
    final random = Random();
    final number = List.generate(9, (_) => random.nextInt(10)).join();
    documentNumberController.text = number;
  }

  double getInterestRate(String currency) {
    return currency == 'KZT' ? 14.0 : 1.0;
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 182)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 7300)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      documentExpiryController.text = DateFormat('dd.MM.yyyy').format(picked);
    }
  }

  Future<void> createAccount() async {
    try {
      isLoading.value = true;

      final result = await accountsController.createAccount(
        accountType.value,
        selectedCurrency.value,
      );

      if (result) {
        Get.back();
        Get.snackbar('Успех', 'Счёт успешно создан');
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось создать счёт');
    } finally {
      isLoading.value = false;
    }
  }
}
