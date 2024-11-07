import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

bool manageNav(bool? condition, Function() navigate, {Function()? onFail}) {
  AuthController authController = Get.find<AuthController>();

  if (!authController.isAuthenticated || (condition ?? false)) {
    if (authController.isCheckingAuth) {
      Get.snackbar('Подождите', 'Идет проверка авторизации');
      onFail?.call();
      return false;
    } else if (!authController.isAuthenticated) {
      Get.toNamed('/phoneLogin');
      onFail?.call();
      return false;
    }
  }

  if (!authController.isLoggedIn || (condition ?? false)) {
    print(
        'authController.isLoggedIn: ${authController.isLoggedIn}, condition: ${(condition ?? false)}');
    Get.toNamed('/codeEntering');
    onFail?.call();
    return false;
  }
  navigate();
  return true;
}
