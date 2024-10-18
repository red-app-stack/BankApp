// import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  // final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get uid => _prefs.getString('uid') ?? '';
  String get role => _prefs.getString('userRole') ?? 'student';

  String getStoragePath([String? customUid]) {
    String uuid = customUid ?? uid;
    switch (role) {
      case 'student':
        return 'profile_pictures/students/$uuid';
      case 'teacher':
        return 'profile_pictures/teachers/$uuid';
      case 'admin':
        return 'profile_pictures/admins/$uuid';
      default:
        return 'profile_pictures/students/$uuid';
    }
  }

  String getDbPath([String? customUid]) {
    String uuid = customUid ?? uid;
    switch (role) {
      case 'student':
        return 'college/students/$uuid';
      case 'teacher':
        return 'college/teachers/$uuid';
      case 'admin':
        return 'college/admins/$uuid';
      default:
        return 'college/students/$uuid';
    }
  }
}
