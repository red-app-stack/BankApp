import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/auth_controller.dart';
import '../shared/widgets.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _secondFieldController;
  late final Animation<double> _secondFieldAnimation;

  @override
  void initState() {
    super.initState();
    _secondFieldController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _secondFieldAnimation = CurvedAnimation(
      parent: _secondFieldController,
      curve: Curves.easeInOut,
    );
  }

  final FocusNode emailFocus = FocusNode();
  final FocusNode codeFocus = FocusNode();

  String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите код подтверждения';
    }
    if (value.length != 6) {
      return 'Код должен содержать 6 цифр';
    }
    if (!_authController.isCodeCorrect && value.length == 6) {
      return 'Введен неверный код';
    }
    return null;
  }

  void sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      if (_authController.obfuscatedEmail != null) {
        if (await _authController
            .checkPartialEmail(_authController.email.value.text)) {
          _authController
              .sendVerificationCode(_authController.email.value.text);
          _secondFieldController.forward();
        } else {
          Get.snackbar('Ошибка', 'Введенный email не совпадает с существующим');
        }
      } else {
        _authController.sendVerificationCode(_authController.email.value.text);
        _secondFieldController.forward();
      }
    }
  }

  @override
  void dispose() {
    _secondFieldController.dispose();
    emailFocus.dispose();
    codeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: fakeHero(
                    tag: 'ic_back',
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
                    )),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Expanded(
                  flex: 3,
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
                                child: Text(
                                  _authController.obfuscatedEmail == null
                                      ? "Введите Ваш личный адрес электронной почты"
                                      : 'Аккаунт с данным телефоном уже зарегистрирован. Введите почту чтобы продолжить.',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontSize: 14,
                                    fontFamily: 'OpenSans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                )),
                            SizedBox(height: size.height * 0.02),
                            fakeHero(
                                tag: 'text_input1',
                                child: TextFormField(
                                  controller: _authController.email.value,
                                  focusNode: emailFocus,
                                  enabled: !_authController.isCodeSent ||
                                      _authController.allowResend,
                                  textInputAction: TextInputAction.send,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: _authController
                                                .obfuscatedEmail !=
                                            null
                                        ? '${_authController.obfuscatedEmail}'
                                        : 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Пожалуйста, введите email';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Введите корректный email адрес';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) async {
                                    if (_authController.obfuscatedEmail !=
                                        null) {
                                      if (await _authController
                                          .checkPartialEmail(_authController
                                              .email.value.text)) {
                                        sendVerificationCode();
                                      } else {
                                        Get.snackbar('Ошибка',
                                            'Введенный email не совпадает с сохраненным');
                                      }
                                    } else {
                                      sendVerificationCode();
                                    }
                                  },
                                )),
                            Obx(() {
                              if (_authController.isCodeSent) {
                                return SizeTransition(
                                  sizeFactor: _secondFieldAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.02),
                                      fakeHero(
                                        tag: 'text_info2',
                                        child: Text(
                                          'Введите код подтверждения',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.outline,
                                            fontSize: 14,
                                            fontFamily: 'OpenSans',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.02),
                                      fakeHero(
                                        tag: 'text_input2',
                                        child: TextFormField(
                                          controller: _authController
                                              .verification.value,
                                          focusNode: codeFocus,
                                          maxLength: 6,
                                          textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Код подтверждения',
                                            prefixIcon:
                                                Icon(Icons.security_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorText: validateVerificationCode(
                                                _authController
                                                    .verification.value.text),
                                          ),
                                          onChanged: (value) => {
                                            _formKey.currentState!.validate(),
                                            _authController
                                                .setIsCodeCorrect(true),
                                          },
                                          onFieldSubmitted: (_) {
                                            _formKey.currentState!.validate();
                                          },
                                          validator: validateVerificationCode,
                                        ),
                                      ),
                                      fakeHero(
                                          tag: 'sub_button',
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                              onPressed:
                                                  _authController.allowResend
                                                      ? () {
                                                          if (_authController
                                                                  .email
                                                                  .value
                                                                  .text
                                                                  .isNotEmpty &&
                                                              GetUtils.isEmail(
                                                                  _authController
                                                                      .email
                                                                      .value
                                                                      .text)) {
                                                            _authController
                                                                .sendVerificationCode(
                                                                    _authController
                                                                        .email
                                                                        .value
                                                                        .text);
                                                          }
                                                        }
                                                      : null,
                                              style: theme.textButtonTheme.style
                                                  ?.copyWith(
                                                foregroundColor:
                                                    WidgetStateProperty
                                                        .all<Color>(theme
                                                            .colorScheme
                                                            .primary),
                                              ),
                                              child: Text(
                                                _authController
                                                            .countdownTimer ==
                                                        0
                                                    ? 'Отправить код повторно'
                                                    : 'Повторная отправка через ${_authController.countdownTimer} сек',
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ),
                  )),
              Expanded(
                flex: 2,
                child: Center(
                  child: fakeHero(
                    tag: 'ic_login',
                    child: SizedBox(
                      height: size.height * 0.3,
                      child: SvgPicture.asset(
                        'assets/icons/illustration_login.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Obx(() => ElevatedButton(
                  onPressed: _authController.isCodeSent
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _authController.verifyCode(
                                _authController.verification.value.text);
                          }
                        }
                      : sendVerificationCode,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _authController.isCodeSent
                                ? "Подтвердить"
                                : "Отправить код",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ))),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
