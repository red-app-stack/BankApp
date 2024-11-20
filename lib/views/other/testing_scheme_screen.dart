import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:graphview/graphview.dart';

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

class TestingSchemeScreen extends StatelessWidget {
  final Graph graph = Graph();
  final AlgorithmType builder = AlgorithmType.sugiyama;

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

  void _buildGraphFromItem(Node parentNode, TestingItem item) {
    Node itemNode = Node.Id(item.title);
    if (parentNode != itemNode) {
      graph.addEdge(parentNode, itemNode);
    }

    if (item.subItems != null) {
      for (var subItem in item.subItems!) {
        _buildGraphFromItem(itemNode, subItem);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Create root node
    Node rootNode = Node.Id('Виды тестирования');
    
    // Build graph structure
    for (var section in sections) {
      _buildGraphFromItem(rootNode, section);
    }

    return Scaffold(
      body: SafeArea(
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
                        'Схема видов тестирования',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 32),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 2.0,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder)
                    ..nodeSeparation = 50
                    ..levelSeparation = 100,
                  paint: Paint()
                    ..color = theme.colorScheme.primary
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    return Card(
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        constraints: BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          node.key?.value?.toString() ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
