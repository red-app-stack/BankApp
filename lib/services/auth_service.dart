import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../views/shared/secure_store.dart';
import 'dio_manager.dart';
import 'user_service.dart';

class AuthService extends GetxService {
  late final DioManager _dio;
  late final SecureStore _secureStore;
  
  // Observable states
  final _isAuthenticated = false.obs;
  final _isLoading = false.obs;
  final _currentUser = Rx<UserModel?>(null);
  
  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  UserModel? get currentUser => _currentUser.value;
  
  // Cached token
  String? _cachedToken;
  
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  AuthService() {
    _dio = Get.find<DioManager>();
    _secureStore = Get.find<SecureStore>();
  }

  @override
  void onClose() {
    _authStateController.close();
    super.onClose();
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    
    _cachedToken = await _secureStore.secureStorage.read(key: 'auth_token');
    return _cachedToken;
  }

  Future<bool> checkAuthStatus() async {
    if (_isLoading.value) return _isAuthenticated.value;
    
    _isLoading.value = true;
    
    try {
      final token = await getToken();
      if (token == null) {
        await _handleUnauthenticated();
        return false;
      }

      try {
        final response = await _dio.get(
          '/auth/verify',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

        final isValid = response.statusCode == 200;
        if (isValid) {
          await _handleAuthenticated();
        } else {
          await _handleUnauthenticated();
        }
        return isValid;
      } catch (e) {
        await _handleUnauthenticated();
        return false;
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleAuthenticated() async {
    _isAuthenticated.value = true;
    _currentUser.value ??= await _fetchUserProfile();
    _authStateController.add(true);
  }

  Future<void> _handleUnauthenticated() async {
    _isAuthenticated.value = false;
    _currentUser.value = null;
    _cachedToken = null;
    await _secureStore.secureStorage.deleteAll();
    _authStateController.add(false);
  }

  Future<UserModel?> _fetchUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _dio.get<Map<String, dynamic>>(
        '/auth/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final userModel = UserModel.fromJson(response.data!);
        await _persistUserData(userModel);
        return userModel;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await _handleUnauthenticated();
      }
    }
    return null;
  }

  Future<void> _persistUserData(UserModel user) async {
    try {
      await _secureStore.secureStorage.write(
        key: 'user_data',
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      print('Error persisting user data: $e');
    }
  }

  Future<void> logout() async {
    _isLoading.value = true;
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => status! < 500,
          ),
        );
      }
    } finally {
      await _handleUnauthenticated();
      _isLoading.value = false;
      Get.offAllNamed('/phoneLogin');
    }
  }
}