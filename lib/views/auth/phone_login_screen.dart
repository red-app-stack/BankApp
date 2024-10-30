import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  PhoneLoginPageState createState() => PhoneLoginPageState();
}

class PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPhoneValid = true;
  final FocusNode phoneFocus = FocusNode();
  final TextEditingController phoneController = TextEditingController();
  final RxString phoneNumber = ''.obs;
  final RxString formattedPhoneNumber = ''.obs;
  String previousNumber = '';
  int _previousPhoneValue = 0;

  void updatePhoneNumber(String value) {
    // Get current cursor position
    int cursorPosition = phoneController.selection.start;

    // Store the current digits for comparison
    String oldDigits =
        _previousPhoneValue.toString().replaceAll(RegExp(r'\D'), '');
    String newDigits = value.replaceAll(RegExp(r'\D'), '');
    // Detect if we're deleting
    bool isDeleting = newDigits.length < oldDigits.length;

    // Format the new digits
    String formatted = '';
    if (newDigits.isNotEmpty) {
      // Handle area code
      if (newDigits.length <= 3) {
        formatted = '($newDigits';
      }
      // Handle first part
      else if (newDigits.length <= 6) {
        formatted = '(${newDigits.substring(0, 3)}) ${newDigits.substring(3)}';
      }
      // Handle second part
      else if (newDigits.length <= 8) {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6)}';
      }
      // Handle last part
      else {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6, 8)}-${newDigits.substring(8, min(10, newDigits.length))}';
      }
    }

    // Calculate new cursor position
    int newCursorPosition;
    if (isDeleting) {
      // When deleting, keep cursor at the same position unless we've deleted a format character
      newCursorPosition = max(0, min(cursorPosition - 1, formatted.length));
    } else {
      // When adding, place cursor after the last digit
      newCursorPosition = formatted.length;
    }

    // Update the text field
    phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    // Store the new value for next comparison
    _previousPhoneValue = int.tryParse(formatted) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ic_back.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Введите Ваш личный номер телефона",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 14,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          focusNode: phoneFocus,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Номер телефона',
                            labelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.outline,
                              fontWeight: FontWeight.normal,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: !_isPhoneValid
                                  ? theme.colorScheme.error
                                  : phoneFocus.hasFocus
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🇰🇿',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+7',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            updatePhoneNumber(value);
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                _isPhoneValid = false;
                              });
                              return 'Пожалуйста, введите номер телефона';
                            }
                            String digitsOnly =
                                value.replaceAll(RegExp(r'\D'), '');
                            if (digitsOnly.length != 10) {
                              setState(() {
                                _isPhoneValid = false;
                              });
                              return 'Введите корректный номер телефона';
                            }
                            setState(() {
                              _isPhoneValid = true;
                            });
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/illustration_login.svg',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Get.toNamed('/emailLogin');
                  }
                },
                style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.secondaryContainer,
                  ),
                ),
                child: Text(
                  "Далее",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
