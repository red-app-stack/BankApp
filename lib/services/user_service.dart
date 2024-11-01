import 'dart:convert';

// import 'package:bank_app/controllers/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Observable user data
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;

  UserService({required this.dio});

  // Retrieve user profile from server
  Future<UserModel?> fetchUserProfile() async {
    try {
      // Retrieve the stored token
      final token = await secureStorage.read(key: 'auth_token');

      if (token == null) {
        // No token found, user is not logged in
        return null;
      }

      // Make authenticated request to get user profile
      final response = await dio.get(
        '/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Parse user data
        final userData = response.data;
        final userModel = UserModel.fromJson(userData);

        // Store user data locally and in memory
        await storeUserLocally(userModel);

        return userModel;
      }
    } on DioException catch (e) {
      // Handle authentication errors
      if (e.response?.statusCode == 401) {
        // Token might be expired, logout user
        await logout();
      }
      print('Error fetching user profile: ${e.message}');
    }
    return null;
  }

  // Securely store user data locally
  Future<void> storeUserLocally(UserModel user) async {
    try {
      // Store user data as encrypted JSON
      await secureStorage.write(
          key: 'user_data', value: user.toJson().toString());

      // Update current user in memory
      _currentUser.value = user;
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  // Retrieve locally stored user data
  Future<UserModel?> retrieveLocalUser() async {
    try {
      final userDataString = await secureStorage.read(key: 'user_data');

      if (userDataString != null) {
        // Parse stored JSON back to UserModel
        final userModel = UserModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(userDataString)));

        // Update current user in memory
        _currentUser.value = userModel;
        return userModel;
      }
    } catch (e) {
      print('Error retrieving local user: $e');
    }
    return null;
  }

  // Logout and clear all stored data
  Future<void> logout() async {
    try {
      // Optional: Call server logout endpoint
      await dio.post('/auth/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear all local storage
      await secureStorage.deleteAll();

      // Clear current user
      _currentUser.value = null;

      // Navigate to login screen
      Get.offAllNamed('/login');
    }
  }

  // Check if user is authenticated
  Future<bool> checkAuthentication() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      // Verify token with backend
      final response = await dio.get(
        '/auth/verify',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// User Model
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      isVerified: json['isVerified'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Extension on login/register to store credentials
// extension AuthExtension on AuthController {
//   Future<void> _securelyStoreCredentials(
//       String token, Map<String, dynamic> userData) async {
//     final secureStorage = const FlutterSecureStorage();

//     // Store authentication token
//     await secureStorage.write(key: 'auth_token', value: token);

//     // Create and store user model
//     final userModel = UserModel.fromJson(userData);
//     final userService = Get.find<UserService>();
//     await userService.storeUserLocally(userModel);
//   }
// }
