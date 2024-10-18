// import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get uid => _prefs.getString('uid') ?? '';
  String get role => _prefs.getString('userRole') ?? 'student';
  String get groupId => _prefs.getString('groupId') ?? '';
  String get subjectId => _prefs.getString('subjectId') ?? '';

  void setString(String key, String value) {
    _prefs.setString(key, value);
  }

  Future<List<Group>> loadGroups() async {
    DataSnapshot groupsSnapshot = await _dbRef.child('college/groups').get();
    List<Group> groupList = [];

    for (var groupSnapshot in groupsSnapshot.children) {
      if (!_isGroupRelevantForUser(groupSnapshot)) {
        continue;
      }

      List<Subject> subjectList = _getSubjectsForGroup(groupSnapshot);

      groupList.add(Group(
        id: groupSnapshot.key ?? '',
        name: groupSnapshot.child('info/name').value as String? ?? '',
        subjects: subjectList,
      ));
    }

    return groupList;
  }

  bool _isGroupRelevantForUser(DataSnapshot groupSnapshot) {
    switch (role) {
      case 'student':
        return groupSnapshot.child('students/$uid').exists;
      case 'teacher':
        return groupSnapshot.child('subjects').children.any((subject) {
          return subject
              .child('info/teacherName')
              .value
              .toString()
              .contains(uid);
        });
      case 'admin':
        return true;
      default:
        return false;
    }
  }

  List<Subject> _getSubjectsForGroup(DataSnapshot groupSnapshot) {
    List<Subject> subjectList = [];

    for (var subject in groupSnapshot.child('subjects').children) {
      if (role == 'teacher') {
        if (subject.child('info/teacherId').value.toString().contains(uid)) {
          subjectList.add(Subject(
            subjectId: subject.key ?? '',
            subjectIndex:
                subject.child('info/subjectId').value as String? ?? '',
            groupId: groupSnapshot.key ?? '',
            name: subject.child('info/name').value as String? ?? '',
            teacherName:
                subject.child('info/teacherName').value as String? ?? '',
            studentCount: groupSnapshot.child('students').children.length,
          ));
        }
        continue;
      } else {
        subjectList.add(Subject(
          subjectId: subject.key ?? '',
          subjectIndex: subject.child('info/subjectId').value as String? ?? '',
          groupId: groupSnapshot.key ?? '',
          name: subject.child('info/name').value as String? ?? '',
          teacherName: subject.child('info/teacherName').value as String? ?? '',
          studentCount: groupSnapshot.child('students').children.length,
        ));
      }
    }

    return subjectList;
  }

  Future<SubjectData> fetchSubjectData(String groupId, String subjectId) async {
    try {
      List<Student> studentsList = [];
      Set<String> uniqueDates = {};
      final [groupSnapshot, studentDataSnapshot, studentGradesSnapshot] =
          await Future.wait([
        _dbRef.child('college/groups/$groupId').get(),
        _dbRef.child('college/students').get(),
        _dbRef.child('college/grades/$groupId/$subjectId/students').get()
      ]);
      if (groupSnapshot.exists && studentDataSnapshot.exists) {
        final studentsSnapshot = groupSnapshot.child('students');
        final students = studentsSnapshot.value as Map<dynamic, dynamic>;

        for (final entry in students.entries) {
          final studentId = entry.key.toString();
          final studentDataNode = studentDataSnapshot.child('$studentId/info');

          if (!studentDataNode.exists) {
            print('Warning: Student data not found for ID: $studentId');
            continue;
          }

          final studentData = studentDataNode.value as Map<dynamic, dynamic>;

          Map<String, String> grades = {};
          final studentGradesNode = studentGradesSnapshot.child(studentId);
          if (studentGradesNode.exists) {
            final gradesData = studentGradesNode.value as Map<dynamic, dynamic>;
            grades = gradesData.map((key, value) {
              final grade = value.toString();
              uniqueDates.add(key.toString());
              return MapEntry(key, grade);
            });
          }

          studentsList.add(Student(
            uid: studentId,
            name: studentData['name'] as String,
            grades: grades,
          ));
        }

        List<String> sortedDates = lexSort(uniqueDates.toList());

        if (subjectId.isNotEmpty) {
          final subjectSnapshot =
              groupSnapshot.child('subjects/$subjectId/info');
          if (!subjectSnapshot.exists) {
            throw Exception('Subject data does not exist');
          }
          final subjectData = subjectSnapshot.value as Map<dynamic, dynamic>;

          return SubjectData(
            subject: Subject(
              subjectId: subjectId,
              subjectIndex: subjectData['subjectId'] ?? '0',
              groupId: groupId,
              name: subjectData['name'] as String,
              teacherName: subjectData['teacherName'],
              studentCount: studentsList.length,
            ),
            groupName: groupSnapshot.child('info/name').value as String,
            students: studentsList,
            dates: sortedDates,
          );
        } else {
          return SubjectData(
            subject: Subject(
              subjectId: '',
              subjectIndex: '',
              groupId: groupId,
              name: '',
              teacherName: '',
              studentCount: studentsList.length,
            ),
            groupName: groupSnapshot.child('info/name').value as String,
            students: studentsList,
            dates: sortedDates,
          );
        }
      } else {
        return SubjectData.empty();
      }
    } catch (e) {
      print('Error fetching subject data: $e');
      rethrow;
    }
  }

  Future<void> updateGrade(String groupId, String subjectId, String studentId,
      String score, String date) async {
    if (subjectId.isEmpty) {
      throw Exception('Subject ID is empty');
    }
    if (studentId.isEmpty) {
      throw Exception('Student ID is empty');
    }
    DatabaseReference gradeRef =
        _dbRef.child('college/grades/$groupId/$subjectId/students/$studentId');

    if (score != '') {
      await gradeRef.child(date).set(score);
    } else {
      await gradeRef.child(date).remove();
      return;
    }
  }

  List<String> lexSort(List<String> dates) {
    return dates
      ..sort((a, b) {
        final partsA = a.split('-');
        final partsB = b.split('-');
        int yearComparison = partsA[2].compareTo(partsB[2]);
        if (yearComparison != 0) return yearComparison;
        int monthComparison = partsA[1].compareTo(partsB[1]);
        if (monthComparison != 0) return monthComparison;
        int dayComparison = partsA[0].compareTo(partsB[0]);
        if (dayComparison != 0) return dayComparison;
        return int.parse(partsA[3]).compareTo(int.parse(partsB[3]));
      });
  }
}

class Group {
  final String id;
  final String name;
  final List<Subject> subjects;
  

  Group({
    required this.id,
    required this.name,
    required this.subjects,
  });
}

class Student {
  final String uid;
  final String name;
  final Map<String, String> grades;

  Student({
    required this.uid,
    required this.name,
    required this.grades,
  });

  String getGradeForDate(String date) {
    return grades[date] ?? "";
  }

  void updateGrade(String date, String score) {
    if (score.isEmpty) {
      grades.remove(date);
    } else {
      grades[date] = score;
    }
  }
}

class Subject {
  final String subjectId;
  final String subjectIndex;
  final String groupId;
  final String name;
  final String teacherName;
  final int studentCount;

  Subject({
    required this.subjectId,
    required this.subjectIndex,
    required this.groupId,
    required this.name,
    required this.teacherName,
    required this.studentCount,
  });

  factory Subject.empty() {
    return Subject(
      subjectId: '',
      subjectIndex: '',
      groupId: '',
      name: '',
      teacherName: '',
      studentCount: 0,
    );
  }
}

class SubjectData {
  final Subject subject;
  final String groupName;
  final List<Student> students;
  final List<String> dates;

  SubjectData({
    required this.subject,
    required this.groupName,
    required this.students,
    required this.dates,
  });

  factory SubjectData.empty() {
    return SubjectData(
      subject: Subject.empty(),
      groupName: '',
      students: [],
      dates: [],
    );
  }
}
