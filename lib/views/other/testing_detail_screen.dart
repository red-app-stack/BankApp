import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TestingDetailsScreen extends StatelessWidget {
  final String title;
  final String? description;
  final List<String>? subItems;

  const TestingDetailsScreen({
    required this.title,
    this.description,
    this.subItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await Future.delayed(const Duration(milliseconds: 500));
            } catch (e) {
              print('Error during refresh: $e');
            }
            return Future.value();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Row(
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
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 32),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                if (description != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                if (subItems != null) ...[
                  SizedBox(height: size.height * 0.02),
                  Card(
                    child: Column(
                      children: [
                        ...subItems!.asMap().entries.map((entry) {
                          final isLast = entry.key == subItems!.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: theme.colorScheme.secondaryContainer,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
