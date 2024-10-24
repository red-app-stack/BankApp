import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/widgets.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  LoginPage({super.key});

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
                          "Вход",
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 40),
                      fakeHero(
                        tag: 'email_input',
                        child: buildTextInput(
                          authController.email.value,
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
                          authController.password.value,
                          "Введите пароль",
                          iconType: 'password',
                          isPassword: true,
                          context: context,
                          currentFocus: passwordFocus,
                        ),
                      ),
                      SizedBox(height: 30),
                      fakeHero(
                        tag: 'main_button',
                        child: Obx(() => ElevatedButton(
                          onPressed: authController.status
                              ? null
                              : () {
                                  // authController.login(
                                  //   authController.email.value.text.trim(),
                                  //   authController.password.value.text.trim(),
                                  // );
                                  // TextInput.finishAutofillContext();
                                },
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: authController.status
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text('Войти'),
                        )),
                      ),
                      SizedBox(height: 20),
                      fakeHero(
                        tag: 'option',
                        child: buildSignInText(
                          "Нет аккаунта?",
                          "Зарегистрироваться",
                          context,
                          () {
                            Get.offNamed(Routes.register);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}