import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                  child: Text(
                    'Введите код подтверждения',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 12,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: theme.colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      hintText: 'Код подтверждения',
                      border: InputBorder.none,
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
                  // Handle code verification logic here
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
