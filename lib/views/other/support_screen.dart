import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class SupportScreen extends StatelessWidget {
  final VoidCallback onBack;

  SupportScreen({
    super.key,
    required this.onBack,
  }) {
    Get.lazyPut(() => ThemeController());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                      child: Column(children: [
                    SizedBox(height: size.height * 0.15),
                    Text('Бот\nконсультант',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.colorScheme.secondaryContainer,
                            fontFamily: 'OpenSans',
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1.1)),
                    SizedBox(height: size.height * 0.02),
                    SvgPicture.asset(
                      'assets/icons/ic_chatbot.svg',
                      height: size.height * 0.3,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.secondaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                  ])),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
              child: _buildTextBarIcons(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBarIcons(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_book.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.outlineVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {},
          color: theme.colorScheme.outlineVariant,
        ),
        Expanded(
          child: Container(
            height: 48,
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                border: InputBorder.none,
                alignLabelWithHint: true,
                hintText: 'Задайте интересующий вопрос',
                hintStyle: TextStyle(
                  color: theme.colorScheme.outline,
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_send.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {},
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
