import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenController extends GetxController {
  final List<String> homeIconPaths = [
    'assets/icons/creditcard.svg',
    'assets/icons/deposits.svg',
    'assets/icons/credits.svg',
    'assets/icons/shopping.svg',
  ];

  final List<String> popularIconPaths = [
    'assets/icons/phone.svg',
    'assets/icons/internet.svg',
    'assets/icons/transport.svg',
    'assets/icons/utilities.svg',
  ];
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeScreenController controller = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            hintText: 'Поиск...',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/support.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Главная',
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[0],
                            label: 'Карты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[1],
                            label: 'Депозиты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[2],
                            label: 'Кредиты',
                            theme: theme),
                        _buildServiceItem(
                            svgPath: controller.homeIconPaths[3],
                            label: 'Рассрочка',
                            theme: theme),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String svgPath,
    String label = '',
    double iconSize = 32,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12), // Soft rounded corners
          splashFactory: InkRipple.splashFactory, // Smoother ripple effect
          splashColor: theme.colorScheme.primary.withOpacity(0.08),
          highlightColor: theme.colorScheme.primary.withOpacity(0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    )),
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

  Widget _buildShimmerLoading({required ThemeData theme}) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainer,
      highlightColor: theme.colorScheme.surfaceBright,
      period: const Duration(seconds: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
