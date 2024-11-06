import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../shared/widgets.dart';

class PasswordEnteringScreen extends StatefulWidget {
  const PasswordEnteringScreen({super.key});

  @override
  PasswordEnteringScreenState createState() => PasswordEnteringScreenState();
}

class PasswordEnteringScreenState extends State<PasswordEnteringScreen> {
  final AuthController _authController = Get.find<AuthController>();
  bool _isPasswordVisible = false;
  bool _isNameValid = true;
  bool _isPasswordValid = true;
  final _formKey = GlobalKey<FormState>();
  int _attempts = 0;
  late Worker _passwordValidityWorker;

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Update the worker to trigger form validation when password correctness changes
    _passwordValidityWorker =
        ever(_authController.isPasswordCorrect, (isCorrect) {
      if (_formKey.currentState != null) {
        setState(() {
          _isPasswordValid = isCorrect ?? true;
          _formKey.currentState!.validate();
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordValidityWorker.dispose();
    // _authController.password.value.dispose();
    // _authController.email.value.dispose();
    // _authController.phone.value.dispose();
    // _authController.verification.value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

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
                      onPressed: () => Get.back(),
                    ),
                  )),
              SizedBox(height: size.height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
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
                              !_authController.isLoggingIn
                                  ? "Введите Ваше полное ФИО"
                                  : 'Здравствуйте! Введите пароль',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                                fontSize: 14,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        fakeHero(
                            tag: 'text_input1',
                            child: TextFormField(
                              controller: _authController.fullName.value,
                              focusNode: _fullNameFocusNode,
                              enabled: !_authController.isLoggingIn,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: !_authController.isLoggingIn
                                    ? 'Введите ФИО'
                                    : 'ФИО',
                                labelStyle: TextStyle(
                                  color: _formKey.currentState?.validate() ==
                                          false
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.normal,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: !_isNameValid
                                      ? Theme.of(context).colorScheme.error
                                      : _fullNameFocusNode.hasFocus
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                  fontWeight: FontWeight.bold,
                                ),
                                hintStyle:
                                    Theme.of(context).textTheme.bodyMedium,
                                prefixIcon: const Icon(Icons.person_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              onFieldSubmitted: (_) {
                                setState(() {});
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    _isNameValid = false;
                                  });
                                  return 'Пожалуйста, введите ФИО';
                                }

                                List<String> nameParts = value
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .where((part) => part.isNotEmpty)
                                    .toList();

                                if (nameParts.length < 3 ||
                                    nameParts.any((part) => part.isEmpty)) {
                                  setState(() {
                                    _isNameValid = false;
                                  });
                                  return 'Введите полное имя с фамилией, именем и отчеством';
                                }
                                setState(() {
                                  _isNameValid = true;
                                });
                                return null;
                              },
                            )),
                        SizedBox(height: size.height * 0.02),
                        fakeHero(
                          tag: 'text_info2',
                          child: Text(
                            !_authController.isLoggingIn
                                ? 'Введите надежный пароль'
                                : _attempts <= -1
                                    ? "Введите новый пароль"
                                    : "Введите Ваш пароль",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                              fontSize: 14,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        fakeHero(
                          tag: 'text_input2',
                          child: TextFormField(
                            controller: _authController.password.value,
                            textInputAction: TextInputAction.done,
                            focusNode: _passwordFocusNode,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Введите пароль',
                              labelStyle: TextStyle(
                                color:
                                    _formKey.currentState?.validate() == false
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.normal,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: !_isPasswordValid
                                    ? Theme.of(context).colorScheme.error
                                    : _passwordFocusNode.hasFocus
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                tooltip:
                                    'Пароль должен содержать заглавные и строчные буквы, цифры и спец. символы',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorMaxLines: 2,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) {
                              setState(() {});
                            },
                            onChanged: (value) {
                              _authController.isPasswordCorrect.value = null;
                              setState(() {
                                _isPasswordValid =
                                    true; // Reset validation state
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() {
                                  _isPasswordValid = false;
                                });
                                return 'Пожалуйста, введите пароль';
                              }

                              if (value.length < 8) {
                                setState(() {
                                  _isPasswordValid = false;
                                });
                                return 'Пароль должен содержать минимум 8 символов';
                              }

                              final passwordRegex = RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');
                              // Пароль должен содержать как минимум одну заглавную букву, одну строчную букву, одну цифру и один спец. символ

                              if (!passwordRegex.hasMatch(value)) {
                                setState(() {
                                  _isPasswordValid = false;
                                });
                                return 'Пароль должен содержать заглавные и строчные буквы, цифры и спец. символы';
                              }
                              if (_authController.isLoggingIn &&
                                  _authController.isPasswordCorrect.value ==
                                      false) {
                                setState(() {
                                  _isPasswordValid = false;
                                });
                                return 'Неверный пароль';
                              }

                              setState(() {
                                _isPasswordValid = true;
                              });
                              return null;
                            },
                          ),
                        ),
                        fakeHero(
                          tag: 'sub_button',
                          child: _attempts >= 3
                              ? Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _attempts = -99;
                                      });
                                    },
                                    style:
                                        theme.textButtonTheme.style?.copyWith(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              theme.colorScheme.primary),
                                    ),
                                    child: Text(
                                      'Восстановить пароль',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: fakeHero(
                    tag: 'ic_login',
                    child: SizedBox(
                      height: size.height * 0.3,
                      child: (theme.brightness == Brightness.dark)
                          ? Container()
                          : SvgPicture.asset(
                              'assets/icons/illustration_login.svg',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Obx(
                () => ElevatedButton(
                  onPressed: _authController.status
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (!_authController.isLoggingIn) {
                              _authController.register();
                            } else {
                              setState(() {
                                _attempts++;
                              });
                              _authController.login();
                            }
                          }
                        },
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      theme.colorScheme.secondaryContainer,
                    ),
                  ),
                  child: _authController.status
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : fakeHero(
                          tag: 'main_button',
                          child: Text(
                            'Продолжить',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                ),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
