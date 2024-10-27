import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final dio = Dio();
  final secureStorage = const FlutterSecureStorage();

  final apiBaseUrl = 'https://bankdevsec5836.serveo.net';
//   /api/v1
  final Rx<TextEditingController> fullName = TextEditingController().obs;
  final Rx<TextEditingController> email = TextEditingController().obs;
  final Rx<TextEditingController> password = TextEditingController().obs;

  final RxBool _status = false.obs;
  bool get status => _status.value;

  final RxString _userRole = RxString('client');
  String get userRole => _userRole.value;

  @override
  void onInit() {
    super.onInit();
    dio.options.baseUrl = apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.interceptors.add(AuthInterceptor());
    checkAuthStatus();
  }

  void setStatus(bool value) => _status.value = value;
  void setRole(String value) => _userRole.value = value;

  Future<void> login() async {
    if (email.value.text.trim().isEmpty || password.value.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      setStatus(true);
      final response = await dio.post('/auth/login', data: {
        'email': email.value.text.trim(),
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final storedHashedPassword = userData[
            'password']; // Assuming this is how you get the stored password

        if (BCrypt.checkpw(password.value.text.trim(), storedHashedPassword)) {
          final token = response.data['token'];

          await _securelyStoreCredentials(token, userData);
          Get.offAllNamed('/main');
          Get.snackbar('Success', 'Login successful');
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

  Future<void> register() async {
    try {
      setStatus(true);

      final response = await dio.post('/auth/register', data: {
        'email': email.value.text.trim(),
        'password': _hashPassword(password.value.text.trim()),
        'fullName': fullName.value.text.trim(),
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await _securelyStoreCredentials(token, userData);
        Get.offAllNamed('/main');
        Get.snackbar('Success', 'Registration successful');
      }
    } on DioException catch (e) {
      _handleApiError(e);
    } finally {
      setStatus(false);
    }
  }

  Future<void> logout() async {
    try {
      setStatus(true);
      await dio.post('/auth/logout');
      await _clearSecureStorage();
      Get.offAllNamed('/login');
    } on DioException catch (e) {
      _handleApiError(e);
    } finally {
      setStatus(false);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token != null) {
        final response = await dio.get('/auth/verify');
        if (response.statusCode == 200) {
          Get.offAllNamed('/main');
        } else {
          await _clearSecureStorage();
          Get.offAllNamed('/login');
        }
      }
    } catch (e) {
      await _clearSecureStorage();
      Get.offAllNamed('/login');
    }
  }

  String _hashPassword(String password) {
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    return hashedPassword;
  }

  Future<void> _securelyStoreCredentials(
      String token, Map<String, dynamic> userData) async {
    await secureStorage.write(key: 'auth_token', value: token);
    final userDataString = jsonEncode(userData);
    await secureStorage.write(key: 'user_data', value: userDataString);
  }

  Future<void> _clearSecureStorage() async {
    await secureStorage.deleteAll();
  }

  void _handleApiError(DioException e) {
    if (e.response?.statusCode == 401) {
      Get.snackbar('Error', 'Invalid credentials');
    } else if (e.response?.statusCode == 403) {
      Get.snackbar('Error', 'Access denied');
    } else {
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  @override
  void onClose() {
    email.value.dispose();
    password.value.dispose();
    fullName.value.dispose();
    super.onClose();
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }
}
