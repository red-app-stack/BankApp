import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'testing_detail_screen.dart';
import 'testing_scheme_screen.dart';

class TestingItem {
  final String title;
  final String? description;
  final List<TestingItem>? subItems;

  TestingItem({
    required this.title,
    this.description,
    this.subItems,
  });
}

class TestingScreen extends StatelessWidget {
  TestingScreen({super.key});

  final List<TestingItem> sections = [
    TestingItem(
      title: 'По хроноголии выполнения',
      subItems: [
        TestingItem(title: 'Комплексное'),
        TestingItem(title: 'Входной текст'),
        TestingItem(title: 'Основное'),
        TestingItem(title: 'Повторное'),
        TestingItem(title: 'Регрессионное'),
        TestingItem(title: 'Приёмочное'),
      ],
    ),
    TestingItem(
      title: 'По фромальности',
      subItems: [
        TestingItem(title: 'По тестам'),
        TestingItem(title: 'Исследовательское'),
        TestingItem(title: 'Специализированное', description: '(свободное)'),
      ],
    ),
    TestingItem(
      title: 'По исполнению кода',
      subItems: [
        TestingItem(
          title: 'Статическое',
          subItems: [
            TestingItem(title: 'Статический анализ кода'),
            TestingItem(title: 'Рецензирование исходного кода'),
          ],
        ),
        TestingItem(title: 'Динамическое'),
      ],
    ),
    TestingItem(
      title: 'По уровню тестирования',
      subItems: [
        TestingItem(title: 'Модульное', description: '(компонентное)'),
        TestingItem(title: 'Интеграционное'),
        TestingItem(title: 'Системное'),
      ],
    ),
    TestingItem(
      title: 'По исполнителям тестирования',
      subItems: [
        TestingItem(title: 'Альфа-тестирование'),
        TestingItem(title: 'Бета-тестирование'),
      ],
    ),
    TestingItem(
      title: 'По целям',
      subItems: [
        TestingItem(title: 'Функциональное'),
        TestingItem(
          title: 'Нефункциональное',
          subItems: [
            TestingItem(title: 'Пользовательского интерфейса'),
            TestingItem(title: 'Удобства использования'),
            TestingItem(title: 'Защищённости'),
            TestingItem(title: 'Инсталляционное'),
            TestingItem(title: 'Конфигурационное'),
            TestingItem(title: 'Совместимости'),
            TestingItem(title: 'Надёжности и восстановления после сбоев'),
            TestingItem(title: 'Локализации'),
            TestingItem(
              title: 'Производительности',
              subItems: [
                TestingItem(title: 'Нагрузочное'),
                TestingItem(title: 'Стабильности'),
                TestingItem(title: 'Стрессовое'),
                TestingItem(title: 'Объёмное'),
                TestingItem(title: 'Масштабируемости'),
              ],
            ),
          ],
        ),
      ],
    ),
    TestingItem(
      title: 'По степени автоматизации',
      subItems: [
        TestingItem(title: 'Ручное'),
        TestingItem(title: 'Полуавтоматизированное'),
        TestingItem(title: 'Автоматизированное'),
      ],
    ),
    TestingItem(
      title: 'По позитивности сценария',
      subItems: [
        TestingItem(title: 'Позитивное'),
        TestingItem(title: 'Негативное'),
      ],
    ),
    TestingItem(
      title: 'По знанию системы',
      subItems: [
        TestingItem(title: 'Белого ящика'),
        TestingItem(title: 'Серого ящика'),
        TestingItem(title: 'Чёрного ящика'),
      ],
    ),
    TestingItem(
      title: 'По разработке тестовых сценариев',
      subItems: [
        TestingItem(title: 'На основе требований'),
        TestingItem(title: 'По вариантам использования'),
        TestingItem(title: 'На основе модели'),
      ],
    ),
    TestingItem(
      title: 'Источники',
    ),
  ];

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
            } on TimeoutException {
              print('Refresh operation timed out');
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
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Виды тестирования',
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                ...sections.map((section) => TestingItemView(item: section)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildServiceItem(
                      theme: theme,
                      label: 'Показать схему',
                      svgPath: 'assets/icons/hub2.svg',
                    ),
                    _buildServiceItem(
                      theme: theme,
                      svgPath: 'assets/icons/logout.svg',
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    String svgPath = 'assets/icons/logout.svg',
    String label = 'Выход',
    double iconSize = 40,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          onTap: () {
            svgPath == 'assets/icons/logout.svg'
                ? SystemNavigator.pop()
                : {Get.to(() => TestingSchemeScreen())};
          },
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    svgPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.inversePrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ) ??
                      Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestingItemView extends StatefulWidget {
  final TestingItem item;
  final int level;

  const TestingItemView({
    required this.item,
    this.level = 0,
    super.key,
  });

  @override
  State<TestingItemView> createState() => _TestingItemViewState();
}

class _TestingItemViewState extends State<TestingItemView> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.item.subItems != null
                ? () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            splashFactory: InkRipple.splashFactory,
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (widget.item.description != null) ...[
                          SizedBox(height: 8),
                          Text(
                            widget.item.description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.item.subItems != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && widget.item.subItems != null)
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                children: widget.item.subItems!
                    .map((subItem) => TestingItemView(
                          item: subItem,
                          level: widget.level + 1,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
