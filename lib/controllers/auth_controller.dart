import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../services/dio_helper.dart';
import '../services/server_check_helper.dart';
import '../services/user_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../views/shared/secure_store.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final ServerHealthService serverHealthService = Get.find();
  final UserService userService = Get.find<UserService>();
  final SecureStore secureStore = Get.find<SecureStore>();

  final dio = Dio();

  final urls = [
    dotenv.env['API_URL_1'] ?? '',
    dotenv.env['API_URL_2'] ?? '',
  ];

  final RxString _availableBaseUrl = RxString('');
  String get apiBaseUrl => _availableBaseUrl.value;
  final RxBool _isCheckingServer = false.obs;

  final Rx<TextEditingController> fullName = TextEditingController().obs;
  final Rx<TextEditingController> email = TextEditingController().obs;
  final Rx<TextEditingController> phone = TextEditingController().obs;
  final Rx<TextEditingController> password = TextEditingController().obs;
  final Rx<TextEditingController> verification = TextEditingController().obs;
  final Rx<TextEditingController> code = TextEditingController().obs;

  bool isLoggingIn = false;
  bool isCreatingCode = false;
  Rx<bool?> isPasswordCorrect = Rx<bool?>(null);

  final RxBool _isCodeSent = false.obs;
  bool get isCodeSent => _isCodeSent.value;

  final RxBool _isCodeCorrect = true.obs;
  bool get isCodeCorrect => _isCodeCorrect.value;

  final RxBool _allowResend = false.obs;
  bool get allowResend => _allowResend.value;

  final RxInt _countdownTimer = 60.obs;
  int get countdownTimer => _countdownTimer.value;
  Timer? _timer;

  final RxBool _status = false.obs;
  bool get status => _status.value;
  bool isAuthenticated = false;
  bool isLoggedIn = false;
  bool isCheckingAuth = false;
  bool displayStatus = false;

  final RxString _userRole = RxString('client');
  String get userRole => _userRole.value;
  Map<String, dynamic>? tempUserData;
  String? tempUserToken;

  String? obfuscatedEmail;
  String? obfuscatedPhoneNumber;

  void setIsCodeCorrect(bool value) => _isCodeCorrect.value = value;
  void setStatus(bool value) => _status.value = value;
  void setCodeSent(bool value) => _isCodeSent.value = value;
  void setRole(String value) => _userRole.value = value;

  // @override
  // void onInit() async {
  //   super.onInit();
  //   await checkServer();
  //   await checkAuthStatus();
  //   // Регулярная проверка соединения выключена, лучше проверять соединение перед операциями чем постоянно.
  // }

  Future<void> checkAuthStatus() async {
    if (isCheckingAuth) return;

    isCheckingAuth = true;
    try {
      bool tokenFound = await userService.tokenFound();
      print('Auth token found: $tokenFound');
      if (tokenFound) {
        await checkServer();
        isAuthenticated = await userService.checkAuthentication();
      } else {
        isAuthenticated = false;
        isCheckingAuth = false;
        await checkServer();
      }

      print('User is authenticated: $isAuthenticated');
      if (isAuthenticated) {
        final userProfile =
            userService.currentUser ?? await userService.fetchUserProfile();
        if (userProfile != null) {
          return;
        }
      }
      await userService.logout();
    } catch (e) {
      print('Auth check error: $e');
    } finally {
      isCheckingAuth = false;
      if (displayStatus) {
        Get.snackbar('Сообщение', 'Аутентификация проверена.');
        displayStatus = false;
      }
    }
  }

  Future<void> checkServer() async {
    if (_isCheckingServer.value) return;
    _isCheckingServer.value = true;
    setStatus(true);

    try {
      final baseUrl = await serverHealthService.findFastestServer();
      dio.options.baseUrl = baseUrl;
    } catch (e) {
      print('Error during server check: $e');
    } finally {
      setStatus(false);
      _isCheckingServer.value = false;
    }
  }

  Future<void> findServer() async {
    Map<String, int> serverResponseTimes = {};

    await Future.wait(
      urls.map((url) async {
        try {
          final stopwatch = Stopwatch()..start();
          final response = await DioRetryHelper.retryRequest(() => dio.get(
                '$url/',
                options: Options(
                  headers: {'Connection': 'keep-alive'},
                  validateStatus: (status) => status == 999,
                  sendTimeout: const Duration(seconds: 8),
                ),
              ));
          stopwatch.stop();
          final responseTime = stopwatch.elapsedMilliseconds;
          print('Response time for $url: ${responseTime}ms');

          if (response.statusCode == 999) {
            serverResponseTimes[url] = responseTime;
          }
        } catch (e) {
          print('Failed to connect to $url: $e');
        }
      }),
    );

    if (serverResponseTimes.isNotEmpty) {
      final fastestServer = serverResponseTimes.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;
      _availableBaseUrl.value = fastestServer;
      print(
          'Selected fastest server: $fastestServer (${serverResponseTimes[fastestServer]}ms)');
    } else {
      _availableBaseUrl.value = '';
      print('No working servers found');
    }
  }

  Timer? _healthCheckTimer;

  Future<void> login() async {
    if (email.value.text.trim().isEmpty || password.value.text.trim().isEmpty) {
      Get.snackbar('Ошибка', 'Заполните все поля');
      return;
    }

    try {
      setStatus(true);
      final response = await DioRetryHelper.retryRequest(
          () => dio.post('/auth/login', data: {
                'email': email.value.text.trim(),
                'password': password.value.text.trim(),
              }));

      if (response.statusCode == 200) {
        print('Got The Data, storing');
        final token = response.data['token'];
        final userData = response.data['user'];

        print('Token: $token');
        print('User Data: $userData');
        await _securelyStoreCredentials(token, userData);

        isPasswordCorrect.value = true;
        isCreatingCode = true;
        Get.offNamed('/codeEntering');
      } else {
        isPasswordCorrect.value = false;
      }
    } on DioException catch (e) {
      isPasswordCorrect.value = false;
      _handleApiError(e);
    } finally {
      setStatus(false);
    }
  }

  Future<void> register() async {
    try {
      setStatus(true);

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/auth/register',
            data: {
              'email': email.value.text.trim(),
              'password': password.value.text.trim(),
              'fullName': fullName.value.text.trim(),
              'phoneNumber': phone.value.text.trim(),
            },
          ));

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final userData = response.data['user'];
        await _securelyStoreCredentials(token, userData);
        isCreatingCode = true;
        Get.offAllNamed('/codeEntering');
        Get.snackbar('Успех', 'Успешная регистрация');
      }
    } on DioException catch (e) {
      _handleApiError(e);
      Get.snackbar('Ошибка', 'Неудачная регистрация');
    } finally {
      setStatus(false);
    }
  }

  Future<void> logout() async {
    try {
      setStatus(true);
      await userService.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      tempUserData = null;
      tempUserToken = null;
      Get.offAllNamed('/phoneLogin');
      setStatus(false);
    }
  }

  Future<Map<String, dynamic>> checkUserExistence({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      if (email == null && phoneNumber == null) {
        return {'error': 'Either email or phone number is required'};
      }

      final requestData = {
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/auth/check-user',
            data: requestData,
          ));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['exists'] == true) {
          return {
            'exists': true,
            'user': {
              'email': data['user']['email'],
              'phoneNumber': data['user']['phoneNumber'],
            }
          };
        } else if (data['exists'] == false) {
          return {
            'exists': false,
            'message': 'User does not exist',
          };
        } else {
          return {'error': 'Unexpected response format'};
        }
      } else {
        return {'error': 'Failed to check user existence'};
      }
    } catch (e) {
      print("Error checking user existence: $e");
      return {'error': 'An error occurred while checking user existence'};
    }
  }

  void checkUserPhone() async {
    setStatus(true);
    final result = await checkUserExistence(
      phoneNumber: phone.value.text.trim(),
    );

    if (result['exists'] == true) {
      obfuscatedEmail = result['user']['email'];
      obfuscatedPhoneNumber = result['user']['phoneNumber'];
      print("User exists with obfuscated data:");
      print("Email: $obfuscatedEmail");
      print("Phone: $obfuscatedPhoneNumber");
    } else if (result['exists'] == false) {
      obfuscatedEmail = null;
      obfuscatedPhoneNumber = null;
      print(result['message']);
    } else {
      print("Error: ${result['error']}");
      obfuscatedEmail = null;
      obfuscatedPhoneNumber = null;
    }
    Get.toNamed('/emailLogin');
    setStatus(false);
  }

  void checkUserAndStoreResults() async {
    final result = await checkUserExistence(
      email: email.value.text.trim(),
      phoneNumber: phone.value.text.trim(),
    );

    if (result['exists'] == true) {
      obfuscatedEmail = result['user']['email'];
      obfuscatedPhoneNumber = result['user']['phoneNumber'];
      print("User exists with obfuscated data:");
      print("Email: $obfuscatedEmail");
      print("Phone: $obfuscatedPhoneNumber");
    } else if (result['exists'] == false) {
      print(result['message']);
    } else {
      print("Error: ${result['error']}");
    }
  }

  Future<bool> checkPartialEmail(String enteredEmail) async {
    setStatus(true);

    try {
      final response = await DioRetryHelper.retryRequest(
          () => dio.post('/auth/check-partial-email', data: {
                'enteredEmail': enteredEmail,
                'obfuscatedEmail': obfuscatedEmail,
              }));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Partial email check error: $e');
      return false;
    } finally {
      setStatus(false);
    }
  }

  Future<void> _securelyStoreCredentials(
      String token, Map<String, dynamic> userData) async {
    await secureStore.secureStore('auth_token', token);

    final userModel = UserModel.fromJson(userData);
    await userService.storeUserLocally(userModel);
  }

  Future<bool> validateAccessCode(String enteredCode) async {
    try {
      setStatus(true);
      final storedHash = await secureStore.secureRead('access_code');
      if (storedHash == null) {
        isLoggedIn = false;
        return false;
      }

      final enteredHash = hashAccessCode(enteredCode);
      isLoggedIn = storedHash == enteredHash;
      return isLoggedIn;
    } catch (e) {
      print('Error validating access code: $e');
      isLoggedIn = false;
      return false;
    } finally {
      setStatus(false);
    }
  }

  String hashAccessCode(String code) {
    final bytes = utf8.encode(code);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _handleApiError(DioException e) {
    if (e.response?.statusCode == 401) {
      // Get.snackbar('Ошибка', 'Неверный логин или пароль');
    } else if (e.response?.statusCode == 403) {
      // Get.snackbar('Ошибка', 'Доступ запрещен');
    } else {
      // Get.snackbar('Ошибка', 'Произошла ошибка сети');
    }
  }

  Future<void> sendVerificationCode(String email) async {
    _isCodeSent.value = true;
    setStatus(true);
    int statuscode = 0;
    try {
      final response = await DioRetryHelper.retryRequest(
          () => dio.post('/auth/send-verification-code', data: {
                'email': email,
              }));
      print(response.statusCode);
      statuscode = response.statusCode ?? 0;
      if (response.statusCode == 200) {
        _allowResend.value = false;
        print('Verification code sent to $email');
        startCountdown();
      } else {
        print(response.statusCode);
      }
    } on DioException catch (e) {
      print('Verification code error $e');
      if (statuscode == 502) sendVerificationCode(email);
      _handleApiError(e);
    } finally {
      if (statuscode != 502) setStatus(false);
    }
  }

  void startCountdown() {
    _countdownTimer.value = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownTimer.value > 0) {
        _countdownTimer.value--;
      } else {
        _timer?.cancel();
        _allowResend.value = true;
      }
    });
  }

  Future<void> verifyCode(String code) async {
    setStatus(true);
    try {
      final response = await DioRetryHelper.retryRequest(
          () => dio.post('/auth/verify-code', data: {
                'code': code,
                'email': email.value.text.trim(),
                'exists': obfuscatedEmail != null,
              }));

      if (response.statusCode == 200) {
        _isCodeCorrect.value = true;
        if (response.data['userData'] != null) {
          fullName.value.text = response.data['userData'];
          isLoggingIn = true;
        }
        print(fullName.value.text);
        print(isLoggingIn);

        if (tempUserToken != null && tempUserData != null) {
          await _securelyStoreCredentials(tempUserToken!, tempUserData!);
        }
        Get.toNamed('/passwordEntering');
      } else {
        _isCodeCorrect.value = false;
        Get.snackbar('Ошибка', 'Неверный код');
      }
    } on DioException catch (e) {
      _isCodeCorrect.value = false;
      _handleApiError(e);
    } finally {
      setStatus(false);
    }
  }

  @override
  void onClose() {
    _healthCheckTimer?.cancel();
    phone.value.dispose();
    email.value.dispose();
    verification.value.dispose();
    fullName.value.dispose();
    password.value.dispose();
    code.value.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
