import 'package:bank_app/controllers/accounts_controller.dart';
import 'package:bank_app/views/shared/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import '../shared/widgets.dart';

class CodeEnteringScreen extends StatefulWidget {
  const CodeEnteringScreen({super.key});

  @override
  CodeEnteringScreenState createState() => CodeEnteringScreenState();
}

class CodeEnteringScreenState extends State<CodeEnteringScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final UserService _userService = Get.find<UserService>();
  final AccountsController _accountsController = Get.find<AccountsController>();
  final FocusNode _codeFocusNode = FocusNode();
  final LocalAuthentication _auth = LocalAuthentication();

  final int _codeLength = 4;
  String _enteredCode = '';
  int creationStage = 0;
  String createdCode = '';

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_authController.secureStore.currentSettings?.useBiometrics == true) {
        _authenticateWithBiometrics();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: isLandscape ? 0.0 : 16.0),
          child: isLandscape
              ? _buildLandscapeLayout(theme, size)
              : _buildPortraitLayout(theme, size),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(ThemeData theme, Size size) {
    return Column(
      children: [
        _buildBackButton(theme),
        SizedBox(height: size.height * 0.02),
        buildUserCard(_userService, theme, size),
        SizedBox(height: size.height * 0.02),
        _buildAccessCodeLabel(theme),
        SizedBox(height: size.height * 0.02),
        _buildCodeIndicators(theme),
        SizedBox(height: size.height * 0.02),
        Expanded(child: _buildNumPad(theme, false, size)),
        SizedBox(height: size.height * 0.01),
        _buildForgotCodeButton(theme),
      ],
    );
  }

  Widget _buildLandscapeLayout(ThemeData theme, Size size) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildBackButton(theme),
              buildUserCard(_userService, theme, size),
              SizedBox(height: size.height * 0.02),
              _buildForgotCodeButton(theme),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAccessCodeLabel(theme),
              SizedBox(height: size.height * 0.01),
              _buildCodeIndicators(theme),
              SizedBox(height: size.height * 0.02),
              _buildNumPad(theme, true, size),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Align(
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
            onPressed: _authController.isCreatingCode
                ? () => Navigator.of(context).pop()
                : _authController.isAuthenticated
                    ? () => Navigator.of(context).pop()
                    : () => Get.toNamed('/phoneLogin'),
          ),
        ));
  }

  Widget _buildAccessCodeLabel(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        _authController.isCreatingCode
            ? creationStage == 0
                ? "Придумайте код доступа"
                : "Повторите код доступа"
            : "Введите код доступа",
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.outline,
          fontSize: 12,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCodeIndicators(ThemeData theme) {
    return Row(
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
    );
  }

  Widget _buildNumPad(ThemeData theme, bool isLandscape, Size size) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableHeight = constraints.maxHeight;
      final availableWidth = constraints.maxWidth;

      final maxWidth = isLandscape ? size.width * 0.25 : size.width * 0.70;

      final verticalSpacing = (availableHeight * 0.05).clamp(5.0, 25.0);

      final aspectRatio = isLandscape
          ? (availableWidth / (availableHeight)).clamp(1.0, 1.5)
          : (availableWidth / availableHeight).clamp(1.0, 1.5);

      return Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: availableHeight,
        ),
        child: GridView.count(
          shrinkWrap: true,

          // Выключенная прокрутка GridView
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: aspectRatio,
          mainAxisSpacing: verticalSpacing,
          crossAxisSpacing: verticalSpacing,
          padding: EdgeInsets.all(verticalSpacing / 2),
          children: [
            for (var i = 1; i <= 9; i++)
              _buildNumericButton(i.toString(), theme),
            _buildBiometricButton(theme),
            _buildNumericButton('0', theme),
            _buildDeleteButton(theme),
          ],
        ),
      );
    });
  }

  Widget _buildForgotCodeButton(ThemeData theme) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: !_authController.isCreatingCode
          ? () {}
          : creationStage == 0
              ? () {}
              : creationStage == 1
                  ? () {
                      _enteredCode = '';
                      createdCode = '';
                      setState(() {
                        creationStage = 0;
                      });
                    }
                  : () {},
      child: Text(
        !_authController.isCreatingCode
            ? 'Забыли код доступа?'
            : creationStage == 0
                ? ''
                : 'Сбросить код доступа',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
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
          _handleCodeEntry();
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
    return !_authController.isCreatingCode
        ? TextButton(
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
          )
        : SizedBox();
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

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        if (_authController.secureStore.currentSettings?.useBiometrics !=
            true) {
          await _showBiometricDialog();
        }

        if (_authController.secureStore.currentSettings?.useBiometrics ==
            true) {
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
        }
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
      _authController.isAuthenticated = true;
      _authController.isLoggedIn = true;
      _handleMainNavigation();
      _accountsController.fetchAccounts();
      print("Authentication successful!");
    } else {
      _authController.isLoggedIn = false;
      print("Authentication failed.");
    }
  }

  Future<void> _showBiometricDialog() async {
    final theme = Theme.of(context);

    return Get.dialog<void>(AlertDialog(
      title: Text(
        'Биометрическая Аутентификация',
        style: theme.textTheme.titleLarge,
      ),
      content: Text(
        'Вы хотите использовать биометрическую аутентификацию?',
        style: theme.textTheme.bodyMedium,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: theme.textButtonTheme.style,
          child: Text(
            'Нет',
            style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              final currentSettings =
                  await _authController.secureStore.loadSettings() ??
                      UserSettings.defaults();
              final updatedSettings =
                  currentSettings.copyWith(useBiometrics: true);
              _authController.secureStore.saveSettings(updatedSettings);
            } finally {
              Get.back();
            }
          },
          style: theme.textButtonTheme.style,
          child: Text(
            'Да',
            style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));
  }

  void _handleCodeEntry() async {
    if (_enteredCode.length == _codeLength) {
      if (_authController.isCreatingCode) {
        if (creationStage == 0) {
          creationStage = 1;
          createdCode = _enteredCode;
          setState(() => _enteredCode = '');
        } else if (creationStage == 1) {
          await _authController.secureStore.secureStore(
              'access_code', _authController.hashAccessCode(_enteredCode));
          _authController.isCreatingCode = false;
          _authController.isAuthenticated = true;
          _authController.isLoggedIn = true;
          _handleMainNavigation();
          Get.find<AccountsController>().fetchAccounts();
        }
      } else {
        final isValid = await _authController.validateAccessCode(_enteredCode);
        if (isValid) {
          _handleMainNavigation();
          Get.find<AccountsController>().fetchAccounts();
        } else {
          setState(() => _enteredCode = '');
          Get.snackbar('Ошибка', 'Неверный код доступа');
        }
      }
    }
  }

  void _handleMainNavigation() {
    if (Get.currentRoute != '/main') {
      Get.offNamed('/main');
    } else {
      Get.offAllNamed('/main');
    }
  }

  @override
  void dispose() {
    _codeFocusNode.dispose();
    super.dispose();
  }
}
