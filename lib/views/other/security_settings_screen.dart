import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
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
                          Text(
                            'Безопасность',
                            style: theme.textTheme.titleLarge,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ]))));
  }
}
