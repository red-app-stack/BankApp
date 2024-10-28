import 'package:bank_app/views/auth/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/views/auth/login_screen.dart';
import '/views/auth/register_screen.dart';
import '/views/main/home_screen.dart';
import '../views/main/main_screen.dart';

class FadeWithHeroTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class ScaleFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    curve = curve ?? Curves.easeInOut;
    
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class Routes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const main = '/main';
  static const verification = '/verification';
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterPage(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.main,
      page: () => MainScreen(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.verification,
      page: () => VerificationPage(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
  ];
}
