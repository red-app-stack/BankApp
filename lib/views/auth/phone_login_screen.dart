import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/auth_controller.dart';
import '../shared/formatters.dart';
import '../shared/widgets.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  PhoneLoginPageState createState() => PhoneLoginPageState();
}

class PhoneLoginPageState extends State<PhoneLoginPage> {
  final AuthController _authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  bool _isPhoneValid = true;
  final FocusNode phoneFocus = FocusNode();
  final RxString phoneNumber = ''.obs;
  final RxString formattedPhoneNumber = ''.obs;
  String previousNumber = '';
  int _previousPhoneValue = 0;

  void updatePhoneNumber(String value) {
    int cursorPosition = _authController.phone.value.selection.start;

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

    _authController.phone.value.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _previousPhoneValue = int.tryParse(formatted) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentLocale = Localizations.localeOf(context);
    });
  }

  @override
  void dispose() {
    phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final botomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: fakeHero(
                    tag: 'ic_back',
                    child: (1 == 1)
                        ? IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/ic_back.svg',
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: (1 == 1)
                                ? () => Navigator.of(context).pop()
                                : () => Get.toNamed('/main'),
                          )
                        : SizedBox(
                            height: 32,
                            width: 32,
                          )),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fakeHero(
                          tag: 'text_info',
                          child: Text("Введите Ваш личный номер телефона",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                                fontSize: 14,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.w400,
                              )),
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        fakeHero(
                            tag: 'text_input1',
                            child: TextFormField(
                              controller: _authController.phone.value,
                              focusNode: phoneFocus,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Номер телефона',
                                labelStyle: TextStyle(
                                  color:
                                      _formKey.currentState?.validate() == false
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
                            )),
                        Center(
                            child: fakeHero(
                          tag: 'ic_login',
                          child: SizedBox(
                            height: size.width <= size.height
                                ? size.height * 0.3
                                : size.width * 0.3,
                            child: (theme.brightness == Brightness.dark)
                                ? Container()
                                : SvgPicture.asset(
                                    'assets/icons/illustration_login.svg',
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              )),
              Obx(() => AnimatedPadding(
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(bottom: botomInset),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            !_authController.status) {
                          print(_authController.phone.value.text.trim());
                          // Лишняя проверка, ведь оно не асинхронно.
                          // authController.verifyServerConnection();
                          _authController.checkUserPhone();
                          _authController.email.value.text = '';
                          _authController.password.value.text = '';
                          _authController.verification.value.text = '';
                          _authController.setCodeSent(false);
                        }
                      },
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          theme.colorScheme.secondaryContainer,
                        ),
                      ),
                      child: fakeHero(
                        tag: 'main_button',
                        child: _authController.status
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                "Далее",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontFamily: 'OpenSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      )))),
              SizedBox(
                  height: botomInset <= size.height * 0.02
                      ? size.height * 0.02
                      : 0),
            ],
          ),
        ),
      ),
    );
  }
}
