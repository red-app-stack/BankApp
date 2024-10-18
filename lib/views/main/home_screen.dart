import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/firebase_service.dart';
import '../../utils/custom_classes.dart';
import '../dialogs/date_creation_dialog.dart';
import '../dialogs/grade_edit_dialog.dart';
import '../scores/group_info_card.dart';

class HomeScreenController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  RxList<String> dates = <String>[].obs;
  List<Student> students = [];
  List<Group> groups = [];
  SubjectData subjectData = SubjectData.empty();
  String groupId = '';
  String subjectId = '';
  String uid = '';
  String role = 'student';
  final Rx<double> columnWidth = 311.0.obs;
  final Rx<double> lastWidth = 311.0.obs;

  bool isLoading = true;

  bool roundStudents = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeData();
  }

  Future<void> initializeData() async {
    try {
      await _firebaseService.initialize();
      uid = _firebaseService.uid;
      role = _firebaseService.role;
      groupId = _firebaseService.groupId;
      subjectId = _firebaseService.subjectId;

      print('INITIALIZE DATA $uid   $role   $groupId   $subjectId');

      await loadGroups();
      synchronize();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      await Future.delayed(Duration(seconds: 1));
      isLoading = false;
      update();
    }
  }

  Future<void> loadGroups() async {
    groups = await _firebaseService.loadGroups();
    // update();
  }

  lexSort() {
    dates.remove('+');
    dates.value = _firebaseService.lexSort(dates.toList());
  }

  Future<void> synchronize() async {
    try {
      subjectData = await _firebaseService.fetchSubjectData(groupId, subjectId);
      dates.value = subjectData.dates;
      if (!dates.contains('+') &&
          (role == 'teacher' || role == 'admin' && subjectId.isNotEmpty)) {
        dates.add('+');
      }

      students = (role == 'teacher' || role == 'admin')
          ? subjectData.students
          : [subjectData.students.firstWhere((student) => student.uid == uid)];
      students.sort((a, b) => a.name.compareTo(b.name));
      await Future.delayed(Duration(milliseconds: 100));
      updateColumnWidth(0);
    } catch (e) {
      print('Error fetching subject data: $e');
    }
  }

  void updateColumnWidth(width) {
    double useWidth = width == 0 ? lastWidth.value : width;
    lastWidth.value = useWidth;
    roundStudents = subjectId == '';
    double newWidth = useWidth - 32 - ((dates.length) * 60);
    if (newWidth < 120) newWidth = 120;

    columnWidth.value = newWidth;
    update();
  }

  void selectGroupAndSubject(Group selectedGroup, Subject? selectedSubject) {
    groupId = selectedGroup.id;
    subjectId = selectedSubject?.subjectId ?? '';
    _firebaseService.setString('groupId', groupId);
    _firebaseService.setString('subjectId', subjectId);
    synchronize();
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeScreenController controller = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Журнал')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GetBuilder<HomeScreenController>(
            init: controller,
            builder: (controller) {
              if (controller.isLoading) {
                return Center(
                    child: _buildShimmerLoading(theme: Theme.of(context)));
              }

              controller.updateColumnWidth(constraints.maxWidth);
              return Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      CardBasedMenu(
                        groups: controller.groups,
                        initialGroup: controller.groups.firstWhereOrNull(
                            (group) => group.id == controller.groupId),
                        initialSubject: controller.subjectId,
                        onSelect: controller.selectGroupAndSubject,
                      ),
                      Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyResizableWidthContainer(
                                key: ValueKey(controller.columnWidth.value),
                                initialWidth: controller.columnWidth.value,
                                minWidth: 60,
                                maxWidth: controller.roundStudents
                                    ? constraints.maxWidth - 32
                                    : constraints.maxWidth *
                                        (controller.columnWidth.value /
                                            constraints.maxWidth),
                                child: _buildStudentColumn(controller),
                              ),
                              if (!controller.roundStudents)
                                Expanded(
                                  child: Scrollbar(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: _buildScoresTable(
                                          controller, context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentColumn(HomeScreenController controller) {
    return Column(
      children: [
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            borderRadius: controller.roundStudents
                ? BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12))
                : BorderRadius.only(topLeft: Radius.circular(12)),
            color: Get.theme.colorScheme.tertiaryContainer,
          ),
          child: Text(
            'Студент',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
        ...controller.students.map((student) => Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: controller.roundStudents &&
                        student == controller.students.last
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12))
                    : student == controller.students.last
                        ? BorderRadius.only(bottomLeft: Radius.circular(12))
                        : BorderRadius.all(Radius.zero),
                color: controller.students.indexOf(student).isOdd
                    ? Get.theme.colorScheme.surface
                    : Get.theme.colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                student.name,
                style: TextStyle(color: Get.theme.colorScheme.onSurface),
              ),
            )),
      ],
    );
  }

  Widget _buildScoresTable(
      HomeScreenController controller, BuildContext context) {
    if (controller.dates.isEmpty || controller.students.isEmpty) {
      if (controller.subjectId.isEmpty) {
        controller.roundStudents = true;
        return SizedBox();
      } else {
        controller.roundStudents = false;
      }
      return Table(defaultColumnWidth: const FixedColumnWidth(60), children: [
        TableRow(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
              color: Get.theme.colorScheme.tertiaryContainer,
            ),
            children: [
              Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      strokeWidth: 2,
                    ),
                  )),
            ]),
      ]);
    }
    return Table(
      defaultColumnWidth: const FixedColumnWidth(60),
      children: [
        TableRow(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
            color: Get.theme.colorScheme.tertiaryContainer,
          ),
          children: controller.dates.map((date) {
            return Container(
              height: 40,
              alignment: Alignment.center,
              child: date == '+'
                  ? IconButton(
                      icon: Icon(Icons.add,
                          color: Get.theme.colorScheme.onTertiaryContainer),
                      onPressed: () {
                        _showAddDialog(controller); // Trigger the dialog
                      },
                    )
                  : Text(
                      '${date.split('-')[0]}.${date.split('-')[1]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
            );
          }).toList(),
        ),
        ...controller.students.map((student) {
          return TableRow(
            decoration: BoxDecoration(
              borderRadius: student == controller.students.last
                  ? BorderRadius.only(bottomRight: Radius.circular(12))
                  : BorderRadius.all(Radius.zero),
              color: controller.students.indexOf(student).isOdd
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            children: controller.dates.map((date) {
              if (date == '+') {
                return Container();
              }
              String score = student.getGradeForDate(date);
              return GestureDetector(
                onTap: () {
                  if (controller.role != 'student') {
                    _showEditDialog(controller, student, date, score);
                  }
                },
                onLongPress: () {
                  Get.snackbar(
                      'Долгое нажатие', 'Имя: ${student.name}, Оценка: $score');
                },
                child: Container(
                  height: 32,
                  margin: EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: score == "Н"
                        ? Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(0.8)
                        : controller.students.indexOf(student).isOdd
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2), // Adds a subtle shadow
                      ),
                    ],
                  ),
                  child: Text(
                    score,
                    style: TextStyle(
                      color: score == "Н"
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildShimmerLoading({required ThemeData theme}) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainer,
      highlightColor: theme.colorScheme.surfaceBright,
      period: const Duration(seconds: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Selection Card Shimmer
          Card(
            margin: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(HomeScreenController controller, Student student,
      String date, String score) {
    Get.dialog(
      GradeEditDialog(
        student: student,
        date: date,
        currentScore: score,
        onSave: (String newScore) {
          controller._firebaseService.updateGrade(
            controller.groupId,
            controller.subjectId,
            student.uid,
            newScore,
            date,
          );
          student.updateGrade(date, newScore);
          controller.update();
        },
      ),
    );
  }

  void _showAddDialog(HomeScreenController controller) {
    Get.dialog(DateCreationDialog(
      initialType: "Обычная оценка",
      onSave: (date, description, type) {
        date = date.replaceAll('.', '-');
        String newDate;

        // Handle the case where dates already exist with a similar format
        List<String> similarDates =
            controller.dates.where((d) => d.startsWith(date)).toList();
        int count = similarDates.length;
        newDate = "$date-$count";

        // Remove the "+" before adding a new date
        controller.dates.remove('+');

        controller.dates.add(newDate);
        controller.lexSort();

        if (controller.role == 'teacher' || controller.role == 'admin') {
          controller.dates.add('+');
        }

        controller.update();
      },
    ));
  }
}
