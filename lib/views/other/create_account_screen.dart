import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/create_account_controller.dart';

class CreateAccountScreen extends StatelessWidget {
  final CreateAccountController controller = Get.put(CreateAccountController());

  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Открыть счёт', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/ic_back.svg'),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountTypeSelector(theme),
                SizedBox(height: 24),
                _buildPersonalInfoSection(theme),
                SizedBox(height: 24),
                _buildFinancialInfoSection(theme),
                SizedBox(height: 24),
                _buildDocumentSection(context),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.createAccount,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Открыть счёт'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип счёта', style: theme.textTheme.titleMedium),
            SizedBox(height: 16),
            Obx(() => SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'card', label: Text('Карта')),
                    ButtonSegment(value: 'deposit', label: Text('Депозит')),
                    ButtonSegment(value: 'credit', label: Text('Кредит')),
                  ],
                  selected: {controller.accountType.value},
                  onSelectionChanged: (Set<String> selection) {
                    controller.accountType.value = selection.first;
                  },
                )),
            SizedBox(height: 16),
            _buildCurrencySelector(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Валюта', style: theme.textTheme.titleSmall),
        SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              children: ['KZT', 'USD', 'EUR'].map((currency) {
                bool isSelected = controller.selectedCurrency.value == currency;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currency),
                      if (controller.accountType.value == 'deposit' &&
                          isSelected)
                        Text(' (${controller.getInterestRate(currency)}%)'),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.selectedCurrency.value = currency;
                  },
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Личные данные', style: theme.textTheme.titleMedium),
            SizedBox(height: 16),
            TextField(
              controller: controller.fullNameController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'ФИО',
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.phoneController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.birthDateController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Дата рождения',
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfoSection(ThemeData theme) {
    return Obx(() => controller.accountType.value == 'credit'
        ? Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Финансовая информация',
                      style: theme.textTheme.titleMedium),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.monthlyIncomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ежемесячный доход',
                      suffixText: controller.selectedCurrency.value,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.additionalIncomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Дополнительный доход',
                      suffixText: controller.selectedCurrency.value,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink());
  }

  Widget _buildDocumentSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Документы', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controller.selectedDocument.value,
              items: controller.documentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) => controller.selectedDocument.value = value!,
              decoration: InputDecoration(
                labelText: 'Тип документа',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.documentNumberController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Номер документа',
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.documentExpiryController,
              decoration: InputDecoration(
                labelText: 'Действителен до',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => controller.selectExpiryDate(context),
            ),
          ],
        ),
      ),
    );
  }

}
