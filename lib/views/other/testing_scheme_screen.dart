import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphview/graphview.dart';
import 'package:graphview/graphview.dart' as graphview;

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

class TestingSchemeScreen extends StatefulWidget {
  @override
  _TestingSchemeScreenState createState() => _TestingSchemeScreenState();
}

class _TestingSchemeScreenState extends State<TestingSchemeScreen> {
  final Graph graph = Graph();

  final SugiyamaConfiguration builder = SugiyamaConfiguration()
    ..nodeSeparation = 50
    ..levelSeparation = 100
    ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
  int _currentOrientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;


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


  void _buildGraphFromItem(graphview.Node parentNode, TestingItem item) {
    graphview.Node itemNode = graphview.Node.Id(item.title);
    graph.addNode(itemNode);
    if (parentNode != itemNode) {
      graph.addEdge(parentNode, itemNode);
    }

    if (item.subItems != null) {
      for (var subItem in item.subItems!) {
        _buildGraphFromItem(itemNode, subItem);
      }
    }
  }

  // Clear the graph before rebuilding
  void _updateOrientation(int newOrientation) {
    setState(() {
      _currentOrientation = newOrientation;
      builder.orientation = _currentOrientation;

      // Clear the graph
      graph.nodes.clear();
      graph.edges.clear();

      // Rebuild graph with new orientation
      graphview.Node rootNode = graphview.Node.Id('Виды тестирования');
      graph.addNode(rootNode);

      // Add new nodes based on the sections
      for (var section in sections) {
        _buildGraphFromItem(rootNode, section);
      }
    });
  }

  Widget _buildControls() {
    return Wrap(
      spacing: 8,
      children: [
        SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: builder.nodeSeparation.toString(),
            decoration: InputDecoration(labelText: "Node Separation"),
            onChanged: (text) {
              setState(() {
                builder.nodeSeparation = int.tryParse(text) ?? 50;
              });
            },
          ),
        ),
        SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: builder.levelSeparation.toString(),
            decoration: InputDecoration(labelText: "Level Separation"),
            onChanged: (text) {
              setState(() {
                builder.levelSeparation = int.tryParse(text) ?? 100;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutControls() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ChoiceChip(
              label: Text('Top-Down'),
              selected: _currentOrientation ==
                  SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM,
              onSelected: (selected) {
                _updateOrientation(
                    SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
              },
            ),
            ChoiceChip(
              label: Text('Left-Right'),
              selected: _currentOrientation ==
                  SugiyamaConfiguration.ORIENTATION_LEFT_RIGHT,
              onSelected: (selected) {
                _updateOrientation(
                    SugiyamaConfiguration.ORIENTATION_LEFT_RIGHT);
              },
            ),
            ChoiceChip(
              label: Text('Bottom-Up'),
              selected: _currentOrientation ==
                  SugiyamaConfiguration.ORIENTATION_BOTTOM_TOP,
              onSelected: (selected) {
                _updateOrientation(
                    SugiyamaConfiguration.ORIENTATION_BOTTOM_TOP);
              },
            ),
            ChoiceChip(
              label: Text('Right-Left'),
              selected: _currentOrientation ==
                  SugiyamaConfiguration.ORIENTATION_RIGHT_LEFT,
              onSelected: (selected) {
                _updateOrientation(
                    SugiyamaConfiguration.ORIENTATION_RIGHT_LEFT);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(Node node, BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        final nodeValue = node.key?.value;
        if (nodeValue != null) {
          print('Tapped node: $nodeValue');
        }
      },
      child: Card(
        elevation: 4,
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
            node.key?.value?.toString() ?? 'Unknown',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create root node
    graphview.Node rootNode = graphview.Node.Id('Виды тестирования');
    graph.addNode(rootNode);

    // Build graph structure from sections
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
            _buildLayoutControls(),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 200, // Adjust the height as needed
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.01,
                maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  paint: Paint()
                    ..color = theme.colorScheme.primary
                    ..strokeWidth = 1.5
                    ..style = PaintingStyle.stroke,
                  builder: (Node node) => _buildNode(node, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
