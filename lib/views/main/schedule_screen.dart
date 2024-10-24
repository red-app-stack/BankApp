import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimetableController extends GetxController {
  List<String> schedule = [
    '1,2,3,0,0,0,0', // Monday
    '4,5,6,1,0,0,0', // Tuesday
    '2,3,4,5,0,0,0', // Wednesday
    '6,1,2,3,4,5,0', // Thursday
    '5,6,7,8,0,0,0', // Friday
    '0,0,0,0,0,0,0', // Saturday (off)
    '0,0,0,0,0,0,0',
  ];

  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<TableRow> tableLayout = [];
  bool tableLayoutVisibility = false;

  // Example map of subjects. You can replace this with real data.
  final Map<int, Subject> subjectsMap = {
    1: Subject(subjectName: 'Math'),
    2: Subject(subjectName: 'English'),
    3: Subject(subjectName: 'Science'),
    4: Subject(subjectName: 'History'),
    5: Subject(subjectName: 'Physics'),
    6: Subject(subjectName: 'Chemistry'),
    7: Subject(subjectName: 'Biology'),
    8: Subject(subjectName: 'PE'),
  };
}

class Subject {
  final String subjectName;

  Subject({required this.subjectName});
}

class ScheduleScreen extends StatelessWidget {
  final TimetableController controller = Get.put(TimetableController());

  ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: controller.schedule.isEmpty
          ? _buildLoadingIndicator(context)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: createTable(controller, context),
              ),
            ),
    );
  }

  String _getSubjectName(String subject) {
    const subjects = {
      '0': 'Free',
      '1': 'Math',
      '2': 'English',
      '3': 'Science',
      '4': 'History',
      '5': 'Physics',
      '6': 'Chemistry',
      '7': 'Biology',
      '8': 'PE',
    };
    return subjects[subject] ?? 'Unknown';
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    );
  }

  Widget createTable(TimetableController controller, BuildContext context) {
    final DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    final List<String> daysOfWeek = List.generate(7, (index) {
      final String dayName;
      switch (index) {
        case 0:
          dayName = 'Пн';
          break;
        case 1:
          dayName = 'Вт';
          break;
        case 2:
          dayName = 'Ср';
          break;
        case 3:
          dayName = 'Чт';
          break;
        case 4:
          dayName = 'Пт';
          break;
        case 5:
          dayName = 'Сб';
          break;
        case 6:
          dayName = 'Вс';
          break;
        default:
          dayName = ' \n ';
      }

      String date =
          '${monday.day.toString().padLeft(2, '0')}.${monday.month.toString().padLeft(2, '0')}';
      monday = monday.add(Duration(days: 1));
      return '$dayName\n$date';
    });

    final List<String> times = [
      "08:00\n \n09:20",
      "09:25\n \n10:45",
      "10:55\n \n12:15",
      "12:25\n \n13:45",
      "13:55\n \n15:15",
      "15:20\n \n16:40",
      "16:45\n \n18:05",
    ];

    // Clear previous table layout
    controller.tableLayout.clear();

    // Header Row
    TableRow headerRow = TableRow(
      children: [
        Container(
          height: 40,
          alignment: Alignment.center,
          child: const Text(
            ' \n ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...daysOfWeek.map((day) {
          String daySchedule =
              controller.schedule[daysOfWeek.indexOf(day)] ?? '0,0,0,0,0,0,0';
          if (daySchedule != '0,0,0,0,0,0,0') {
            return Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }
          return Container();
        }),
      ],
    );
    controller.tableLayout.add(headerRow);

    // Time Rows with subjects
    for (var time in times) {
      List<Widget> timeRowChildren = [
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ];

      for (var i = 0; i < daysOfWeek.length; i++) {
        String currentDaySchedule = controller.schedule[i] ?? '';
        List<String> subjectIds = currentDaySchedule.split(',');

        int timeIndex = times.indexOf(time);
        String subjectId =
            subjectIds.length > timeIndex ? subjectIds[timeIndex] : '0';
        var subjectInfo = controller.subjectsMap[int.parse(subjectId)];

        timeRowChildren.add(
          GestureDetector(
            onTap: subjectInfo != null
                ? () {
                    _showEditDialog(context, subjectInfo.subjectName);
                  }
                : null,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                subjectInfo?.subjectName ?? ' \n \n ',
                style: TextStyle(
                  color: subjectInfo != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }

      TableRow timeRow = TableRow(children: timeRowChildren);
      controller.tableLayout.add(timeRow);
    }

    controller.tableLayoutVisibility = true;

    // Returning the Table widget
    return Table(
      border: TableBorder.all(),
      defaultColumnWidth: const FixedColumnWidth(80),
      children: controller.tableLayout,
    );
  }

  void _showEditDialog(BuildContext context, String subject) {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Subject'),
        content: Text('Editing $subject'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle edit action
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
