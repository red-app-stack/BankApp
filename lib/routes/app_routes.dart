import 'package:bank_app/views/auth/code_entering_screen.dart';
import 'package:bank_app/views/auth/verification_screen.dart';
import 'package:bank_app/views/other/profile_screen.dart';
import 'package:bank_app/views/other/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/main/transfers_screen.dart';
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

class ZoomFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Using a custom curve combination for smoother animation
    final zoomCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    );

    final fadeCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: fadeCurve,
      child: ScaleTransition(
        alignment: alignment ?? Alignment.center,
        scale: Tween<double>(
          begin: 0.85, // Slightly larger starting scale for subtler effect
          end: 1.0,
        ).animate(zoomCurve),
        child: child,
      ),
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
    // Using separate curves for scale and fade for more dynamic effect
    final scaleCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(
        0.0,
        0.9, // Scale completes slightly before fade
        curve: Curves.easeOutCubic,
      ),
    );

    final fadeCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(
        0.2, // Fade starts after scale begins
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    return ScaleTransition(
      alignment: alignment ?? Alignment.center,
      scale: Tween<double>(
        begin: 0.92, // More subtle scale effect
        end: 1.0,
      ).animate(scaleCurve),
      child: FadeTransition(
        opacity: fadeCurve,
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
  static const profile = '/profile';
  static const codeEntering = '/codeEntering';
  static const verification = '/verification';
  static const transfers = '/transfers';
  static const phoneTransfer = '/phoneTransfer';
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
      name: Routes.codeEntering,
      page: () => CodeEnteringScreen(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.verification,
      page: () => VerificationScreen(),
      customTransition: FadeWithHeroTransition(),
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.transfers,
      page: () => TransfersScreen(),
      customTransition: ZoomFadeTransition(),
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.phoneTransfer,
      page: () => PhoneTransferScreen(),
      customTransition: ZoomFadeTransition(),
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfileScreen(
        onBack: () {},
      ),
      customTransition: ZoomFadeTransition(),
      transitionDuration: Duration(milliseconds: 400),
    ),
  ];
}
