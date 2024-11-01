import 'dart:async';
import 'package:bank_app/services/interceptor.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final UserService userService = Get.find<UserService>();

  final dio = Dio();
  final secureStorage = const FlutterSecureStorage();

  final urls = [
    dotenv.env['API_URL_1'] ?? '',
    dotenv.env['API_URL_2'] ?? '',
  ];

  final RxString _availableBaseUrl = RxString('');
  String get apiBaseUrl => _availableBaseUrl.value;
  final RxBool _isCheckingServer = false.obs;
  final RxInt _retryAttempts = 0.obs;
  final int maxRetries = 5;

  final Rx<TextEditingController> fullName = TextEditingController().obs;
  final Rx<TextEditingController> email = TextEditingController().obs;
  final Rx<TextEditingController> phone = TextEditingController().obs;
  final Rx<TextEditingController> password = TextEditingController().obs;
  final Rx<TextEditingController> verification = TextEditingController().obs;

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

  final RxString _userRole = RxString('client');
  String get userRole => _userRole.value;
  Map<String, dynamic>? tempUserData;
  String? tempUserToken;

  void setIsCodeCorrect(bool value) => _isCodeCorrect.value = value;
  void setStatus(bool value) => _status.value = value;
  void setCodeSent(bool value) => _isCodeSent.value = value;
  void setRole(String value) => _userRole.value = value;

  @override
  void onInit() async {
    super.onInit();
    await checkServer();
    // Регулярная проверка соединения выключена, лучше проверять соединение перед операциями чем постоянно.
    // startServerHealthCheck();
  }

  Future<void> checkServer() async {
    if (_isCheckingServer.value) return;
    _isCheckingServer.value = true;
    setStatus(true);

    try {
      if (_availableBaseUrl.value.isEmpty) {
        await findServer();
      }

      if (_availableBaseUrl.value.isNotEmpty) {
        dio.options.baseUrl = apiBaseUrl;
        dio.options.connectTimeout = const Duration(seconds: 10);
        dio.options.receiveTimeout = const Duration(seconds: 10);
        dio.interceptors.add(AuthInterceptor());
        await checkAuthStatus();
        _retryAttempts.value = 0;
      } else if (_retryAttempts.value < maxRetries) {
        _retryAttempts.value++;
        print('Retry attempt ${_retryAttempts.value} of $maxRetries');
        await Future.delayed(Duration(seconds: 2));
        await checkServer();
      } else {
        print('Max retry attempts reached');
        Get.snackbar('Error', 'Unable to connect to server');
      }
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
          final response = await dio.get(
            '$url/',
            options: Options(
              headers: {'Connection': 'keep-alive'},
              validateStatus: (status) => status == 404,
              sendTimeout: const Duration(seconds: 8),
            ),
          );
          stopwatch.stop();
          final responseTime = stopwatch.elapsedMilliseconds;
          print('Response time for $url: ${responseTime}ms');

          if (response.statusCode == 404) {
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

  void startServerHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => verifyServerConnection(),
    );
  }

  Future<void> verifyServerConnection() async {
    print('Server health check!');
    try {
      if (_availableBaseUrl.value.isEmpty) {
        print('No server available, skipping health check');
        await checkServer();
        return;
      }

      final response = await dio.get(
        '${_availableBaseUrl.value}/',
        options: Options(
          validateStatus: (status) => status == 404,
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode != 404) {
        print('Server connection lost, finding new server');
        _availableBaseUrl.value = '';
        await checkServer();
      } else {
        print('Server connection is fine');
      }
    } catch (e) {
      print('Server health check failed: $e');
      _availableBaseUrl.value = '';
      await checkServer();
    }
  }

  // Future<void> login() async {
  //   if (email.value.text.trim().isEmpty || password.value.text.trim().isEmpty) {
  //     Get.snackbar('Error', 'Please fill all fields');
  //     return;
  //   }

  //   try {
  //     setStatus(true);
  //     final response = await dio.post('/auth/login', data: {
  //       'email': email.value.text.trim(),
  //       'password': password.value.text.trim(),
  //     });

  //     if (response.statusCode == 200) {
  //       final userData = response.data['user'];
  //       final storedHashedPassword = userData['password'];

  //       if (BCrypt.checkpw(password.value.text.trim(), storedHashedPassword)) {
  //         _isCodeSent.value = true;
  //         _allowResend.value = false;
  //         sendVerificationCode(email.value.text.trim());
  //         Get.offNamed('/verification');
  //         Get.snackbar('Success', 'Login successful');

  //         tempUserData = userData;
  //         tempUserToken = response.data['token'];
  //       } else {
  //         Get.snackbar('Error', 'Invalid credentials');
  //       }
  //     }
  //   } on DioException catch (e) {
  //     _handleApiError(e);
  //   } finally {
  //     setStatus(false);
  //   }
  // }

  Future<void> login() async {
    if (email.value.text.trim().isEmpty || password.value.text.trim().isEmpty) {
      Get.snackbar('Ошибка', 'Заполните все поля');
      return;
    }

    try {
      setStatus(true);
      final response = await dio.post('/auth/login', data: {
        'email': email.value.text.trim(),
        'password': password.value.text.trim(),
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final storedHashedPassword = userData['password'];

        if (BCrypt.checkpw(password.value.text.trim(), storedHashedPassword)) {
          _isCodeSent.value = true;
          _allowResend.value = false;
          sendVerificationCode(email.value.text.trim());

          tempUserData = userData;
          tempUserToken = response.data['token'];

          Get.offNamed('/verification');
        } else {
          Get.snackbar('Error', 'Invalid credentials');
        }
      }
    } on DioException catch (e) {
      _handleApiError(e);
    } finally {
      setStatus(false);
    }
  }

  // Future<void> register() async {
  //   await verifyServerConnection();
  //   try {
  //     setStatus(true);

  //     final response = await dio.post('/auth/register', data: {
  //       'email': email.value.text.trim(),
  //       'password': password.value.text.trim(),
  //       'fullName': fullName.value.text.trim(),
  //       'phoneNumber': phone.value.text.trim(),
  //     });
  //     print(phone.value.text.trim());
  //     if (response.statusCode == 201) {
  //       final token = response.data['token'];
  //       final userData = response.data['user'];

  //       await _securelyStoreCredentials(token, userData);
  //       Get.offAllNamed('/main');
  //       Get.snackbar('Успех', 'Успешная регистрация');
  //     }
  //   } on DioException catch (e) {
  //     _handleApiError(e);
  //     Get.snackbar('Ошибка', 'Неудачная регистрация');
  //   } finally {
  //     setStatus(false);
  //   }
  // }

  Future<void> register() async {
    await verifyServerConnection();
    try {
      setStatus(true);

      final response = await dio.post('/auth/register', data: {
        'email': email.value.text.trim(),
        'password': password.value.text.trim(),
        'fullName': fullName.value.text.trim(),
        'phoneNumber': phone.value.text.trim(),
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await _securelyStoreCredentials(token, userData);
        Get.offAllNamed('/main');
        Get.snackbar('Успех', 'Успешная регистрация');
      }
    } on DioException catch (e) {
      _handleApiError(e);
      Get.snackbar('Ошибка', 'Неудачная регистрация');
    } finally {
      setStatus(false);
    }
  }

  // Future<void> logout() async {
  //   try {
  //     setStatus(true);
  //     final token = await _getAccessToken();

  //     await dio.post(
  //       '/auth/logout',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //     );
  //   } on DioException catch (e) {
  //     _handleApiError(e);
  //   } finally {
  //     await _clearSecureStorage();
  //     tempUserData = null;
  //     tempUserToken = null;
  //     Get.offAllNamed('/phoneLogin');
  //     setStatus(false);
  //   }
  // }

  Future<void> logout() async {
    try {
      setStatus(true);
      await userService.logout();
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar('Ошибка', 'Неудачная попытка выхода');
    } finally {
      tempUserData = null;
      tempUserToken = null;
      Get.offAllNamed('/phoneLogin');
      setStatus(false);
    }
  }

  // Future<void> checkAuthStatus() async {
  //   try {
  //     final token = await secureStorage.read(key: 'auth_token');
  //     if (token != null) {
  //       final response = await dio.get('/auth/verify');
  //       if (response.statusCode == 200) {
  //         Get.offAllNamed('/main');
  //       } else {
  //         await _clearSecureStorage();
  //         Get.offAllNamed('/phoneLogin');
  //       }
  //     }
  //   } catch (e) {
  //     await _clearSecureStorage();
  //     Get.offAllNamed('/phoneLogin');
  //   }
  // }

  Future<void> checkAuthStatus() async {
    try {
      final isAuthenticated = await userService.checkAuthentication();

      if (isAuthenticated) {
        final userProfile = await userService.fetchUserProfile();
        if (userProfile != null) {
          Get.offAllNamed('/main');
        } else {
          await userService.logout();
        }
      } else {
        Get.offAllNamed('/phoneLogin');
      }
    } catch (e) {
      print('Auth check error: $e');
      await userService.logout();
    }
  }

  Future<void> _securelyStoreCredentials(
      String token, Map<String, dynamic> userData) async {
    // Store token
    await userService.secureStorage.write(key: 'auth_token', value: token);

    // Create and store user model
    final userModel = UserModel.fromJson(userData);
    await userService.storeUserLocally(userModel);
  }

  // Future<void> _securelyStoreCredentials(
  //     String token, Map<String, dynamic> userData) async {
  //   await secureStorage.write(key: 'auth_token', value: token);
  //   final userDataString = jsonEncode(userData);
  //   await secureStorage.write(key: 'user_data', value: userDataString);
  // }

  // Future<void> _clearSecureStorage() async {
  //   await secureStorage.deleteAll();
  // }

  void _handleApiError(DioException e) {
    if (e.response?.statusCode == 401) {
      Get.snackbar('Ошибка', 'Неверный логин или пароль');
    } else if (e.response?.statusCode == 403) {
      Get.snackbar('Ошибка', 'Доступ запрещен');
    } else {
      Get.snackbar('Ошибка', 'Произошла ошибка сети');
    }
  }

  Future<void> sendVerificationCode(String email) async {
    _isCodeSent.value = true;
    setStatus(true);
    int statuscode = 0;
    try {
      final response = await dio.post('/auth/send-verification-code', data: {
        'email': email,
      });
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
    verifyServerConnection();
    setStatus(true);
    try {
      final stopwatch = Stopwatch()..start();
      final response = await dio.post('/auth/verify-code', data: {
        'code': code,
        'email': email.value.text.trim(),
      });
      stopwatch.stop();
// Если ответ был слишком быстрый, то ждем, чтобы не перегружать пользователя и сервер
      if (stopwatch.elapsedMilliseconds < 2000) {
        await Future.delayed(
            Duration(milliseconds: 2000 - stopwatch.elapsedMilliseconds));
      }

      if (response.statusCode == 200) {
        _isCodeCorrect.value = true;
        if (tempUserToken != null && tempUserData != null) {
          await _securelyStoreCredentials(tempUserToken!, tempUserData!);
        }
        Get.toNamed('/passwordEntering');
      } else {
        _isCodeCorrect.value = false;
        Get.snackbar('Error', 'Invalid code');
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
    email.value.dispose();
    phone.value.dispose();
    _healthCheckTimer?.cancel();
    verification.value.dispose();
    password.value.dispose();
    fullName.value.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
