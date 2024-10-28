import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../shared/widgets.dart';

class VerificationPage extends StatelessWidget {
  final TextEditingController codeController = TextEditingController();
  final AuthController authController = AuthController.instance;

  VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
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
                      "Код Подтверждения",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Введите код, отправленный на вашу почту",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  fakeHero(
                    tag: 'verification_input',
                    child: buildTextInput(
                      codeController,
                      "Код подтверждения",
                      context: context,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 30),
                  fakeHero(
                    tag: 'main_button',
                    child: Obx(() => ElevatedButton(
                          onPressed: authController.isCodeSent
                              ? () {
                                  if (codeController.text.trim().isNotEmpty) {
                                    authController
                                        .verifyCode(codeController.text.trim());
                                  } else {
                                    Get.snackbar(
                                        'Error', 'Введите код подтверждения');
                                  }
                                }
                              : null,
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: authController.isCodeSent
                              ? Text('Подтвердить')
                              : SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                        )),
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    return (authController.isCodeSent &&
                            authController.countdownTimer > 0)
                        ? Column(
                            children: [
                              Text(
                                  "Отправить повторно через ${authController.countdownTimer} секунд"),
                              if (authController.countdownTimer == 0)
                                fakeHero(
                                  tag: 'option',
                                  child: buildSignInText(
                                    "Не пришел код?",
                                    "Переотправить",
                                    context,
                                    () {
                                      authController.sendVerificationCode(
                                          authController.email.value.text
                                              .trim());
                                    },
                                  ),
                                ),
                            ],
                          )
                        : fakeHero(
                            tag: 'option',
                            child: buildSignInText(
                              "Не пришел код?",
                              "Переотправить",
                              context,
                              () {
                                authController.sendVerificationCode(
                                    authController.email.value.text.trim());
                              },
                            ),
                          );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
