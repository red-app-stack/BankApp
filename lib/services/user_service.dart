import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../views/shared/secure_store.dart';
import 'dio_helper.dart';

class UserService extends GetxController {
  final Dio dio;
  final secureStore = Get.find<SecureStore>();
  bool? isTokenFound;
  // Observable user data
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;

  UserService({required this.dio});

  Future<UserModel?> fetchUserProfile() async {
    print('Fetching user profile');
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) {
        return null;
      }
      final response = await DioRetryHelper.retryRequest(() => dio.get(
            '/auth/profile',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          ));

      if (response.statusCode == 200) {
        final userData = response.data;
        final userModel = UserModel.fromJson(userData);
        print('Got user: $userModel');
        await storeUserLocally(userModel); // Store user data locally
        return userModel; // Return the user model
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Got error: $e');
        await userLogout();
      }
      print('Error fetching user profile: ${e.message}');
    } finally {
      print('Done checking');
    }
    return null; // Return null if fetching fails
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
        await DioRetryHelper.retryRequest(() => dio.post(
              '/auth/logout',
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
                validateStatus: (status) => status! < 500,
              ),
            )).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('Logout request timed out, proceeding with local logout');
            throw TimeoutException('Logout request timed out');
          },
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

  Future<bool> tokenFound() async {
    final token = await secureStore.secureStorage.read(key: 'auth_token');
    if (token == null) {
      isTokenFound = false;
      return false;
    } else {
      isTokenFound = true;
      return true;
    }
  }

  // Check if user is authenticated
  Future<bool> checkAuthentication() async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      print('Token found: ${token != null}'); // Add this debug line

      if (token == null) {
        isTokenFound = false;
        return false;
      } else {
        isTokenFound = true;
      }

      final response = await DioRetryHelper.retryRequest(() => dio.get(
            '/auth/verify',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          )
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

  String getInitials(String fullName) {
    List<String> names = fullName.trim().split(RegExp(r'\s+'));

    // Ensure we have at least two parts
    if (names.length < 2) return '';

    String firstNameInitial =
        names[0].isNotEmpty ? names[0][0].toUpperCase() : '';
    String lastNameInitial =
        names[1].isNotEmpty ? names[1][0].toUpperCase() : '';

    return firstNameInitial + lastNameInitial;
  }
}

// User Model
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'client',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
