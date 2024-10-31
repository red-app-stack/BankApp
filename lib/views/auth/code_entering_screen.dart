import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class CodeEnteringScreen extends StatefulWidget {
  const CodeEnteringScreen({super.key});

  @override
  CodeEnteringScreenState createState() => CodeEnteringScreenState();
}

class CodeEnteringScreenState extends State<CodeEnteringScreen> {
  final FocusNode _codeFocusNode = FocusNode();
  final TextEditingController _codeController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  final int _codeLength = 4;
  String _enteredCode = '';

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      _authenticateWithBiometrics();
    });
    super.initState();
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
                  onPressed: () => Get.toNamed('/phoneLogin'),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          'ВВ',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Владислав \nВасильевич Ш.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Введите код доступа",
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 12,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _codeLength,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: index < _enteredCode.length
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      color: index < _enteredCode.length
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildNumericButton(i.toString(), theme),
                      _buildBiometricButton(theme),
                      _buildNumericButton('0', theme),
                      _buildDeleteButton(theme),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              TextButton(
                onPressed: () {
                  // Handle forgotten code logic
                },
                child: Text(
                  'Забыли код доступа?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericButton(String value, ThemeData theme) {
    return TextButton(
      onPressed: () {
        if (_enteredCode.length < _codeLength) {
          setState(() {
            _enteredCode += value;
          });
          if (_enteredCode.length == _codeLength) {
            Get.offAllNamed('/main');
          }
        }
      },
      style: TextButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: theme.colorScheme.surfaceContainer,
        padding: EdgeInsets.all(4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildBiometricButton(ThemeData theme) {
    return TextButton(
      onPressed: () {
        _authenticateWithBiometrics();
      },
      style: TextButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: theme.colorScheme.surfaceContainer,
        padding: EdgeInsets.all(4),
      ),
      child: SvgPicture.asset(
        'assets/icons/ic_biometry.svg',
        width: 48,
        height: 48,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;

    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        authenticated = await _auth.authenticate(
          localizedReason: 'Используйте Touch ID для входа в суперприложение',
          options: const AuthenticationOptions(
            stickyAuth: true,
            useErrorDialogs: true,
            biometricOnly: true,
            sensitiveTransaction: true,
          ),
          authMessages: <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Вход в суперприложение',
              cancelButton: 'Отмена',
              biometricHint: ' ',
              biometricNotRecognized: 'Отпечаток не распознан',
              biometricSuccess: 'Успешно',
            ),
            IOSAuthMessages(
              cancelButton: 'Отмена',
              goToSettingsButton: 'Настройки',
              goToSettingsDescription: 'Настройте биометрию',
              lockOut: 'Включите биометрию',
            ),
          ],
        );
      } else {
        Get.snackbar(
            'Сообщение', 'Touch ID не поддерживается на этом устройстве');
        print("Biometric authentication is not available");
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Touch ID недоступен');
      print("Error during biometric authentication: $e");
    }

    if (authenticated) {
      Get.offAllNamed('/main');
      print("Authentication successful!");
    } else {
      print("Authentication failed.");
    }
  }

  Widget _buildDeleteButton(ThemeData theme) {
    return TextButton(
      onPressed: () {
        if (_enteredCode.isNotEmpty) {
          setState(() {
            _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1);
          });
        }
      },
      style: TextButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: theme.colorScheme.surfaceContainer,
        padding: EdgeInsets.all(4),
      ),
      child: SvgPicture.asset(
        'assets/icons/ic_clear.svg',
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeFocusNode.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
