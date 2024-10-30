import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CodeEnteringScreen extends StatefulWidget {
  const CodeEnteringScreen({super.key});

  @override
  CodeEnteringScreenState createState() => CodeEnteringScreenState();
}

class CodeEnteringScreenState extends State<CodeEnteringScreen> {
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
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(alignment: Alignment.center, children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Container(),
                        ),
                        Text(
                          'ВВ',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ]),
                      SizedBox(height: 12),
                      Text(
                        'Владислав\nВасильевич Ш.',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildNumericButton('1'),
                    _buildNumericButton('2'),
                    _buildNumericButton('3'),
                    _buildNumericButton('4'),
                    _buildNumericButton('5'),
                    _buildNumericButton('6'),
                    _buildNumericButton('7'),
                    _buildNumericButton('8'),
                    _buildNumericButton('9'),
                    Container(), // Empty container for spacing
                    _buildNumericButton('0'),
                    _buildIconButton(
                      'assets/icons/ic_clear.svg',
                      'Delete',
                      () => _codeController.text = _codeController.text.substring(0, _codeController.text.length - 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
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
                  'Забыли код доступа?',
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

  Widget _buildNumericButton(String value) {
    return ElevatedButton(
      onPressed: () {
        _codeController.text += value;
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildIconButton(String assetPath, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}