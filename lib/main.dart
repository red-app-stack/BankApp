// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
// import 'controllers/theme_controller.dart';
import 'services/firebase_options.dart';
import 'utils/static_background.dart';
import 'utils/themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController());
  // final themeController = Get.put(ThemeController());
  // await themeController.onInit();
  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeController = Get.find<ThemeController>();
    // print('Current Theme from builder: ${themeController.themeMode.value}');

    // return ThemeProvider(
    //   initTheme: themeController.themeData.value,
    //   builder: (context, theme) {
    return GetMaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('ru'),
        const Locale('en'),
      ],
      title: 'Банк',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.login,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return
            // ThemeSwitchingArea(
            // child:
            StaticBackgroundWrapper(
          child: child ?? Container(),
          // ),
        );
      },
    );
    //   },
    // );
  }
}
