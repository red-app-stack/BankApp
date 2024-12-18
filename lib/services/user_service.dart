import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../views/shared/secure_store.dart';
import 'dio_manager.dart';

class UserService extends GetxController {
  final DioManager dio = Get.find<DioManager>();
  final secureStore = Get.find<SecureStore>();
  String? token;

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;

  UserService();

  Future<UserModel?> fetchUserProfile() async {
    print('Fetching user profile');
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) {
        return null;
      }
      final response = await dio.get<Map<String, dynamic>>(
        '/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data!;
        final userModel = UserModel.fromJson(userData);
        print('Got user: $userModel');
        await storeUserLocally(userModel);
        return userModel;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        await userLogout();
      }
    } finally {
      print('Done checking');
    }
    return null;
  }

  Future<void> storeUserLocally(UserModel user) async {
    try {
      await secureStore.secureStorage
          .write(key: 'user_data', value: user.toJson().toString());

      _currentUser.value = user;
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  Future<UserModel?> retrieveLocalUser() async {
    try {
      final userDataString =
          await secureStore.secureStorage.read(key: 'user_data');

      if (userDataString != null) {
        final userModel = UserModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(userDataString)));

        _currentUser.value = userModel;
        return userModel;
      }
    } catch (e) {
      print('Error retrieving local user: $e');
    }
    return null;
  }

  Future<void> logout() async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token != null) {
        await dio.post(
          '/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => status! < 500,
          ),
        );
      }
    } catch (e) {
      print('Logout attempt failed: $e');
    } finally {
      // Always clear local data
      await secureStore.secureStorage.deleteAll();
      _currentUser.value = null;
    }
  }

  Future<void> userLogout() async {
    try {
      await logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      Get.offAllNamed('/phoneLogin');
    }
  }

  Future<String?> findToken() async {
    return token ??= await secureStore.secureStorage.read(key: 'auth_token');
  }

  Future<bool> checkAuthentication() async {
    try {
      await findToken();
      print('Token found: $token');

      if (token == null) {
        return false;
      }

      final response = await dio.get(
        '/auth/verify',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Auth response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Auth check failed: $e');
      return false;
    }
  }
}
