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
                    "Введите Ваш личный адрес электронной почты",
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 12,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                )),
            SizedBox(height: 16),
            _buildEmailInput(theme),
            Spacer(),
            SvgPicture.asset(
              'assets/icons/illustration_login.svg',
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed('/verification'),
              style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                theme.colorScheme.secondaryContainer,
              )),
              child: Text(
                "Отправить код",
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

  Widget _buildEmailInput(ThemeData theme) {
    return Card(
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              focusNode: emailFocus,
              keyboardType: TextInputType.emailAddress,
              style: theme.textTheme.titleMedium,
              onSubmitted: (_) {
                Get.toNamed('/verification');
              },
              decoration: InputDecoration(
                hintText: 'Адрес электронной почты',
                border: InputBorder.none,
              ),
            )));
  }
}
