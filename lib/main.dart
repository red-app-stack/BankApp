import 'package:bank_app/services/interceptor.dart';
import 'package:bank_app/services/user_service.dart';
import 'package:bank_app/views/shared/secure_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'controllers/accounts_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/shared/static_background.dart';
import 'utils/themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final startTime = DateTime.now();
  await dotenv.load();
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL_1'] ?? '',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  dio.interceptors.add(AuthInterceptor());
  Get.put(SecureStore());
  final userService = UserService(dio: dio);
  Get.put(userService);
  Get.put(AccountsController(dio: dio));
  AuthController authController = Get.put(AuthController());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await userService.fetchUserProfile();
  await authController.checkAuthStatus();
  final endTime = DateTime.now();
  final timePassed = endTime.difference(startTime);
  if (timePassed.inSeconds < 2) {
    await Future.delayed(Duration(seconds: 2 - timePassed.inSeconds));
  }

  final themeController = Get.put(ThemeController());
  await themeController.loadSavedSettings();

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('ru', 'RU'),
        const Locale('en', 'US'),
        const Locale('kk', 'KZ'),
      ],
      fallbackLocale: const Locale('ru', 'RU'),
      title: 'Банк',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().themeMode.value,
      initialRoute: Routes.main,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return StaticBackgroundWrapper(
          child: child ?? Container(),
        );
      },
    );
  }
}
