import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../shared/widgets.dart';
import '../../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';

class RegisterPage extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 500.0 : double.infinity,
                ),
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      fakeHero(
                        tag: 'title',
                        child: Text(
                          "Регистрация",
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 40),
                      fakeHero(
                        tag: 'fullname_input',
                        child: buildTextInput(
                          _authController.fullName.value,
                          "Введите ФИО",
                          iconType: 'profile',
                          context: context,
                          currentFocus: fullNameFocus,
                          nextFocus: emailFocus,
                        ),
                      ),
                      fakeHero(
                        tag: 'email_input',
                        child: buildTextInput(
                          _authController.email.value,
                          "Введите почту",
                          iconType: 'email',
                          context: context,
                          keyboardType: TextInputType.emailAddress,
                          currentFocus: emailFocus,
                          nextFocus: passwordFocus,
                        ),
                      ),
                      fakeHero(
                        tag: 'password_input',
                        child: buildTextInput(
                          _authController.password.value,
                          "Введите пароль",
                          iconType: 'password',
                          isPassword: true,
                          context: context,
                          currentFocus: passwordFocus,
                        ),
                      ),
                      fakeHero(
                        tag: 'status_toggle',
                        child: _buildStatusToggle(context),
                      ),
                      SizedBox(height: 30),
                      fakeHero(
                        tag: 'main_button',
                        child: ElevatedButton(
                          onPressed: _authController.status
                              ? null
                              : () => _authController.register(),
                          child: _authController.status
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text('Зарегистрироваться'),
                        ),
                      ),
                      SizedBox(height: 20),
                      fakeHero(
                        tag: 'option',
                        child: buildSignInText(
                          "Уже зарегистрированы?",
                          "Войти",
                          context,
                          () {
                            Get.offNamed(Routes.phoneLogin);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (_authController.status) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(BuildContext context) {
    return Obx(() => Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text("Я", style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: _authController.userRole == 'teacher'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _authController.setRole('student'),
                            behavior: HitTestBehavior.opaque,
                            child: _buildToggleOption(
                                context: context,
                                title: "Студент",
                                isSelected:
                                    _authController.userRole != 'teacher'),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _authController.setRole('teacher'),
                            behavior: HitTestBehavior.opaque,
                            child: _buildToggleOption(
                                context: context,
                                title: "Преподаватель",
                                isSelected:
                                    _authController.userRole == 'teacher'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildToggleOption(
      {required BuildContext context,
      required String title,
      required bool isSelected}) {
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.outline,
        fontWeight: FontWeight.bold,
      ),
      duration: Duration(milliseconds: 200),
      child: Center(child: Text(title)),
    );
  }
}
