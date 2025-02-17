import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/create_account_controller.dart';
import '../shared/custom_input_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends State<CreateAccountScreen> {
  final CreateAccountController controller =
      Get.find<CreateAccountController>();

  // Add focus nodes
  final FocusNode monthlyIncomeFocus = FocusNode();
  final FocusNode additionalIncomeFocus = FocusNode();
  final FocusNode documentNumberFocus = FocusNode();
  final FocusNode documentExpiryFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.accountType.value = Get.arguments ?? 'card';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildHeader(context),
                  SizedBox(height: size.height * 0.02),
                  _buildCurrencySection(theme),
                  SizedBox(height: size.height * 0.02),
                  _buildPersonalInfoSection(theme),
                  SizedBox(height: size.height * 0.02),
                  _buildFinancialInfoSection(context),
                  SizedBox(height: size.height * 0.02),
                  _buildDocumentSection(context),
                  SizedBox(height: size.height * 0.02),
                  _buildSubmitButton(theme),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_back.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => {
                  FocusScope.of(context).unfocus(),
                  Get.back(),
                }),
        Expanded(
          child: Text(
            'Открыть ${_formatAccountType(controller.accountType.value)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  String _formatAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return 'карту';
      case 'deposit':
        return 'депозит';
      case 'credit':
        return 'кредит';
      default:
        return 'счёт';
    }
  }

  Widget _buildCurrencySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Валюта',
                style: theme.textTheme.titleMedium,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              final currencies = ['KZT', 'USD', 'EUR'];
              final isDepositAccount =
                  controller.accountType.value == 'deposit';
              final selectedCurrency = controller.selectedCurrency.value;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return IntrinsicHeight(
                    child: Row(
                      children:
                          List.generate(currencies.length * 2 - 1, (index) {
                        if (index.isOdd) {
                          return SizedBox(width: 8);
                        }

                        final currencyIndex = index ~/ 2;
                        final currency = currencies[currencyIndex];
                        final isSelected = selectedCurrency == currency;

                        return Flexible(
                          flex: isSelected ? 3 : 2,
                          child: ChoiceChip(
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(currency),
                                if (isDepositAccount && isSelected)
                                  Text(
                                      ' (${controller.getInterestRate(currency)}%)'),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCurrency.value = currency;
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
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
            CustomInputField(
              controller: controller.fullNameController,
              label: 'ФИО',
              prefixIcon: Icons.person_outline,
              enabled: false,
              filled: true,
            ),
            SizedBox(height: 16),
            CustomInputField(
              controller: controller.phoneController,
              label: 'Номер телефона',
              prefixIcon: Icons.phone_outlined,
              enabled: false,
              filled: true,
            ),
            SizedBox(height: 16),
            CustomInputField(
              controller: controller.birthDateController,
              label: 'Дата рождения',
              prefixIcon: Icons.calendar_today_outlined,
              enabled: false,
              filled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfoSection(BuildContext context) {
    return Obx(() => controller.accountType.value == 'credit'
        ? Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Финансовая информация',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 16),
                  CustomInputField(
                    controller: controller.monthlyIncomeController,
                    focusNode: monthlyIncomeFocus,
                    label: 'Ежемесячный доход',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                    keyboardType: TextInputType.number,
                    suffix: controller.selectedCurrency.value,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(additionalIncomeFocus),
                  ),
                  SizedBox(height: 16),
                  CustomInputField(
                    controller: controller.additionalIncomeController,
                    focusNode: additionalIncomeFocus,
                    label: 'Дополнительный доход',
                    prefixIcon: Icons.add_card_outlined,
                    keyboardType: TextInputType.number,
                    suffix: controller.selectedCurrency.value,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Тип документа',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
              items: controller.documentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) => controller.selectedDocument.value = value!,
            ),
            SizedBox(height: 16),
            CustomInputField(
              controller: controller.documentNumberController,
              label: 'Номер документа',
              prefixIcon: Icons.numbers_outlined,
              enabled: false,
              filled: true,
            ),
            SizedBox(height: 16),
            CustomInputField(
              controller: controller.documentExpiryController,
              label: 'Действителен до',
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () => controller.selectExpiryDate(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                controller.isNotUsCitizen.value =
                    !controller.isNotUsCitizen.value;
              });
            },
            splashColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            highlightColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(width: 12),
                SizedBox(
                    width: 24,
                    height: 24,
                    child: IgnorePointer(
                      child: Checkbox(
                        value: controller.isNotUsCitizen.value,
                        onChanged: (bool? value) {
                          setState(() {
                            controller.isNotUsCitizen.value = value ?? false;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Я не являюсь гражданином / налогоплательщиком США",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: controller.isNotUsCitizen.value
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.createAccount,
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Открыть ${_formatAccountType(controller.accountType.value)}'),
            ),
          ),
        ],
      ),
    ));
  }
}
