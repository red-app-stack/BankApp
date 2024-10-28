//main_screen.dart // page 3
import 'package:bank_app/views/main/accounts_screen.dart';
import 'package:bank_app/views/main/transfers_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'payments_screen.dart';
import 'menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Some placeholders for now
  final List<Widget> _screens = [
    PaymentsScreen(),
    TransfersScreen(),
    HomeScreen(),
    AccountsScreen(),
    MenuScreen(),
  ];
  final List<String> _iconPaths = [
    'assets/icons/payments.svg',
    'assets/icons/transfers.svg',
    'assets/icons/home.svg',
    'assets/icons/accounts.svg',
    'assets/icons/menu.svg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Duration _calculateAnimationDuration(int currentIndex, int newIndex) {
    int distance = (currentIndex - newIndex).abs();
    int duration = 200 + (distance * 200);
    return Duration(milliseconds: duration.clamp(200, 1000));
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    final duration = _calculateAnimationDuration(_selectedIndex, index);

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildIcon(int index) {
    final bool isSelected = index == _selectedIndex;
    final String iconPath = _iconPaths[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 40 : 30,
      height: isSelected ? 40 : 30,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: SvgPicture.asset(
          iconPath,
          colorFilter: isSelected
              ? ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                )
              : ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: CurvedNavigationBar(
          color: Theme.of(context).colorScheme.surfaceContainer,
          buttonBackgroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.transparent,
          index: _selectedIndex,
          items: List.generate(
            _iconPaths.length,
            (index) => _buildIcon(index),
          ),
          onTap: _onItemTapped,
          animationDuration: Duration(milliseconds: 500),
          animationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
