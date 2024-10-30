import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _isCodeValid = true;

  final FocusNode _codeFocusNode = FocusNode();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              SizedBox(height: 24),
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
                          'Введите код подтверждения',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 14,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Код подтверждения',
                            labelStyle: TextStyle(
                              color: _formKey.currentState?.validate() == false
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.outline,
                              fontWeight: FontWeight.normal,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: !_isCodeValid
                                  ? theme.colorScheme.error
                                  : _codeFocusNode.hasFocus
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                            hintStyle: theme.textTheme.bodyMedium,
                            prefixIcon: Icon(
                              Icons.security_outlined,
                              color: !_isCodeValid
                                  ? theme.colorScheme.error
                                  : _codeFocusNode.hasFocus
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
                              Get.toNamed('/passwordEntering');
                            }
                            setState(() {});
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                _isCodeValid = false;
                              });
                              return 'Пожалуйста, введите код подтверждения';
                            }
                            if (value.length != 6) {
                              setState(() {
                                _isCodeValid = false;
                              });
                              return 'Код должен содержать 6 цифр';
                            }
                            setState(() {
                              _isCodeValid = true;
                            });
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Spacer(),
              SvgPicture.asset(
                'assets/icons/illustration_login.svg',
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/passwordEntering');
                },
                style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.secondaryContainer,
                  ),
                ),
                child: Text(
                  'Подтвердить',
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
