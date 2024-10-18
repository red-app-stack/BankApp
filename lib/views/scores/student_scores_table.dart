// import 'package:flutter/material.dart';
// // import '../main/home_screen.dart';

// class StudentScoresTable extends StatefulWidget {
//   final List<String> students;
//   final List<String> dates;
//   final Map<String, Map<String, Map<String, String>>> scores;
//   final Function(String, String, String) onScoreEdit;

//   const StudentScoresTable({
//     super.key,
//     required this.students,
//     required this.dates,
//     required this.scores,
//     required this.onScoreEdit,
//   });

//   @override
//   StudentScoresTableState createState() => StudentScoresTableState();
// }

// class StudentScoresTableState extends State<StudentScoresTable> {
//   double _dividerPosition = 0.3;
//   final ScrollController _horizontalController = ScrollController();
//   final ScrollController _verticalController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Column(
//           children: [
//             _buildHeader(constraints),
//             Expanded(
//               child: _buildBody(constraints),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildHeader(BoxConstraints constraints) {
//     return SizedBox(
//       height: 56,
//       child: Row(
//         children: [
//           Container(
//             width: constraints.maxWidth * _dividerPosition,
//             alignment: Alignment.center,
//             color: Theme.of(context).colorScheme.surfaceContainerHighest,
//             child: Text(
//               'Студент',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: _buildHeaderDates(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderDates() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       controller: _horizontalController,
//       child: Row(
//         children: widget.dates.map((date) {
//           return Container(
//             width: 80,
//             alignment: Alignment.center,
//             color: Theme.of(context).colorScheme.surfaceContainerHighest,
//             child: Text(
//               date,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBody(BoxConstraints constraints) {
//     return Row(
//       children: [
//         SizedBox(
//           width: constraints.maxWidth * _dividerPosition,
//           child: _buildStudentColumn(),
//         ),
//         GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onHorizontalDragUpdate: (details) {
//             setState(() {
//               _dividerPosition += details.delta.dx / constraints.maxWidth;
//               _dividerPosition = _dividerPosition.clamp(0.1, 0.6);
//             });
//           },
//           child: Container(
//             width: 8,
//             color: Theme.of(context).colorScheme.surfaceContainerHighest,
//             child: Center(
//               child: Container(
//                 width: 4,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: _buildScoresTable(constraints.maxWidth * (1 - _dividerPosition) - 8),
//         ),
//       ],
//     );
//   }

//   Widget _buildStudentColumn() {
//     return ListView.builder(
//       controller: _verticalController,
//       itemCount: widget.students.length,
//       itemBuilder: (context, index) {
//         return Container(
//           height: 48,
//           alignment: Alignment.centerLeft,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: index.isEven
//                 ? Theme.of(context).colorScheme.surface
//                 : Theme.of(context).colorScheme.surfaceContainerHighest,
//             border: Border(
//               bottom: BorderSide(
//                 color: Theme.of(context).colorScheme.outlineVariant,
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Text(
//             widget.students[index],
//             style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildScoresTable(double width) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       controller: _horizontalController,
//       child: SizedBox(
//         width: widget.dates.length * 80.0,
//         child: ListView.builder(
//           controller: _verticalController,
//           itemCount: widget.students.length,
//           itemBuilder: (context, studentIndex) {
//             final student = widget.students[studentIndex];
//             return Container(
//               height: 48,
//               color: studentIndex.isEven
//                   ? Theme.of(context).colorScheme.surface
//                   : Theme.of(context).colorScheme.surfaceContainerHighest,
//               child: Row(
//                 children: widget.dates.map((date) {
//                   final gradeData = widget.scores[student]?[date] ?? {'gradeId': '', 'score': ''};
//                   final score = gradeData['score'] ?? '';
//                   return GestureDetector(
//                     onTap: () => _showEditDialog(student, date, score),
//                     onLongPress: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Long pressed: $student, $date')),
//                       );
//                     },
//                     child: Container(
//                       width: 80,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         border: Border(
//                           right: BorderSide(
//                             color: Theme.of(context).colorScheme.outlineVariant,
//                             width: 0.5,
//                           ),
//                           bottom: BorderSide(
//                             color: Theme.of(context).colorScheme.outlineVariant,
//                             width: 0.5,
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         score,
//                         style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showEditDialog(String student, String date, String currentScore) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         String newScore = currentScore;
//         return AlertDialog(
//           title: Text('Edit Score'),
//           content: TextField(
//             autofocus: true,
//             decoration: InputDecoration(hintText: "Enter new score"),
//             onChanged: (value) {
//               newScore = value;
//             },
//             controller: TextEditingController(text: currentScore),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () {
//                 widget.onScoreEdit(student, date, newScore); // The gradeId is still stored in widget.scores
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }