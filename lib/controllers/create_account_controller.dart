import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';
import 'accounts_controller.dart';


class CreateAccountController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final AccountsController accountsController = Get.find<AccountsController>();

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
    'Паспорт РК',
    'Вид на жительство',
    'Заграничный паспорт',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _generateDocumentNumber();
  }

  void _initializeUserData() {
    final user = userService.currentUser;
    if (user != null) {
      fullNameController.text = user.fullName;
      phoneController.text = user.phoneNumber;
      // Add birth date if available in user model
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
      initialDate: DateTime.now().add(Duration(days: 3650)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7300)),
    );
    
    if (picked != null) {
      documentExpiryController.text = 
          DateFormat('dd.MM.yyyy').format(picked);
    }
  }

  Future<void> createAccount() async {
    try {
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
    }
  }
}
