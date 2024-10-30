import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/auth_controller.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  EmailLoginPageState createState() => EmailLoginPageState();
}

class EmailLoginPageState extends State<EmailLoginPage> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = true;

  final FocusNode emailFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();

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
                          "Введите Ваш личный адрес электронной почты",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 14,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          focusNode: emailFocus,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.outline,
                              fontWeight: FontWeight.normal,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
                                  ? theme.colorScheme.error
                                  : emailFocus.hasFocus
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                            hintStyle: theme.textTheme.bodyMedium,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: _formKey.currentState?.validate() == false
                                  ? theme.colorScheme.error
                                  : emailFocus.hasFocus
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
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
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState!.validate()) {
                              Get.toNamed('/verification');
                            }
                            setState(() {});
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                _isEmailValid = false;
                              });
                              return 'Пожалуйста, введите email';
                            }
                            if (!GetUtils.isEmail(value)) {
                              setState(() {
                                _isEmailValid = false;
                              });
                              return 'Введите корректный email адрес';
                            }
                            setState(() {
                              _isEmailValid = true;
                            });
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              SvgPicture.asset(
                'assets/icons/illustration_login.svg',
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Get.toNamed('/verification');
                  }
                },
                style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.secondaryContainer,
                  ),
                ),
                child: Text(
                  "Отправить код",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
