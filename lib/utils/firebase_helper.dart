import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  final FirebaseDatabase database  = FirebaseDatabase.instance;

  Future<void> updateGrade(String groupId, String subjectId, String studentId, String date,  String grade) async {
    await database.ref().child('college/groups/$groupId/subjects/$subjectId/students/$studentId/grades/$date').set(grade);
  }

  Future<DataSnapshot> fetchGrades(String groupId, String subjectId) async {
    DataSnapshot snapshot = await database.ref().child('college/groups/$groupId/subjects/$subjectId/students').get();
    return snapshot;
  }
}
