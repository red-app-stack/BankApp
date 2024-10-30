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
  final FocusNode phoneFocus = FocusNode();
  final TextEditingController phoneController = TextEditingController();
  String? _previousPhoneValue;

  void updatePhoneNumber(String value) {
    int cursorPosition = phoneController.selection.start;
    String oldDigits = _previousPhoneValue?.replaceAll(RegExp(r'\D'), '') ?? '';
    String newDigits = value.replaceAll(RegExp(r'\D'), '');
    bool isDeleting = newDigits.length < oldDigits.length;
    String formatted = '';

    if (newDigits.isNotEmpty) {
      if (newDigits.length <= 3) {
        formatted = '($newDigits';
      } else if (newDigits.length <= 6) {
        formatted = '(${newDigits.substring(0, 3)}) ${newDigits.substring(3)}';
      } else if (newDigits.length <= 8) {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6)}';
      } else {
        formatted =
            '(${newDigits.substring(0, 3)}) ${newDigits.substring(3, 6)}-${newDigits.substring(6, 8)}-${newDigits.substring(8, 10)}';
      }
    }

    int newCursorPosition = isDeleting
        ? max(0, min(cursorPosition - 1, formatted.length))
        : formatted.length;

    phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _previousPhoneValue = formatted;
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
                      theme.colorScheme.primary, BlendMode.srcIn),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            SizedBox(height: 24),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Введите Ваш личный номер телефона",
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 12,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                )),
            SizedBox(height: 16),
            _buildPhoneInput(theme),
            Spacer(),
            SvgPicture.asset(
              'assets/icons/illustration_login.svg',
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed('/emailLogin'),
              style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                theme.colorScheme.secondaryContainer,
              )),
              child: Text(
                "Далее",
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    ));
  }

  Widget _buildPhoneInput(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
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
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleMedium,
                    onSubmitted: (_) {
                      Get.toNamed('/emailLogin');
                    },
                    decoration: InputDecoration(
                      hintText: '(000) 000-00-00',
                      border: InputBorder.none,
                    ),
                    onChanged: updatePhoneNumber,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Visibility(
                      visible: phoneController.text.isNotEmpty,
                      child: Text(
                        'Доверенный номер',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
