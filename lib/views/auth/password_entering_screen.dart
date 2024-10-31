import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

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

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _fullNameFocusNode.dispose();
    _passwordFocusNode.dispose();
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
              ),
              SizedBox(height: size.height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Регистрация',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextFormField(
                          controller: _authController.fullName.value,
                          focusNode: _fullNameFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Введите ФИО',
                            labelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.normal,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: !_isNameValid
                                  ? Theme.of(context).colorScheme.error
                                  : _fullNameFocusNode.hasFocus
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
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
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextFormField(
                          controller: _authController.password.value,
                          textInputAction: TextInputAction.done,
                          focusNode: _passwordFocusNode,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Введите пароль',
                            labelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
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
                            ),
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
                            _authController.status
                                ? null
                                : {
                                    if (_formKey.currentState!.validate())
                                      {_authController.register()}
                                  };
                            setState(() {});
                          },
                          onChanged: (value) {
                            setState(() {}); // Trigger rebuild to update colors
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
                            setState(() {
                              _isPasswordValid = true;
                            });
                            return null;
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Obx(
                () => ElevatedButton(
                  onPressed: _authController.status
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _authController.register();
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Продолжить',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
