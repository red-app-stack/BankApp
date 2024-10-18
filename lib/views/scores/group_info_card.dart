import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class CardBasedMenu extends StatefulWidget {
  final List<Group> groups;
  final Group? initialGroup;
  final String? initialSubject;
  final Function(Group, Subject?) onSelect;

  const CardBasedMenu({
    super.key,
    required this.groups,
    required this.onSelect,
    this.initialGroup,
    this.initialSubject,
  });

  @override
  CardBasedMenuState createState() => CardBasedMenuState();
}

class CardBasedMenuState extends State<CardBasedMenu> {
  Group? selectedGroup;
  Subject? selectedSubject;

  @override
  void initState() {
    super.initState();
    print('CardBasedMenu');
    selectedGroup = widget.initialGroup;
    String? sub = widget.initialSubject;
    if (sub != null && sub.isNotEmpty) {
      selectedSubject = selectedGroup?.subjects
          .firstWhere((subject) => subject.subjectId == widget.initialSubject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Группа', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<Group>(
              decoration: InputDecoration(
                labelText: 'Выберите группу',
                labelStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.outline, // Unselected color
                  fontWeight: FontWeight.normal,
                ),
                floatingLabelStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface, // Selected color
                  fontWeight: FontWeight.bold,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline, // Unselected color
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .inverseSurface, // Selected color
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              value: selectedGroup,
              isExpanded: true,
              items: widget.groups.map((Group group) {
                return DropdownMenuItem<Group>(
                  value: group,
                  child: Text(group.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (Group? newValue) {
                setState(() {
                  selectedGroup = newValue;
                  selectedSubject = null;
                  widget.onSelect(selectedGroup!, null);
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedGroup != null && selectedGroup!.subjects.isNotEmpty)
              DropdownButtonFormField<Subject>(
                decoration: InputDecoration(
                  labelText: 'Выберите предмет',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .outline, // Unselected color
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .inverseSurface, // Selected color
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline, // Unselected color
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .inverseSurface, // Selected color
                      width: 2.0,
                    ),
                  ),
                  // You can also adjust the filled background if needed
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                value: selectedSubject,
                isExpanded: true,
                items: selectedGroup!.subjects.map((Subject subject) {
                  return DropdownMenuItem<Subject>(
                    value: subject,
                    child: Text(subject.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (Subject? newValue) {
                  setState(() {
                    selectedSubject = newValue;
                    widget.onSelect(selectedGroup!, selectedSubject!);
                  });
                },
              ),
            if (selectedSubject != null) ...[
              const SizedBox(height: 16),
              Text('Группа: ${selectedGroup!.name}',
                  overflow: TextOverflow.ellipsis),
              Text('Предмет: ${selectedSubject!.name}'),
              Text('Преподаватель: ${selectedSubject!.teacherName}',
                  overflow: TextOverflow.ellipsis),
              Text('Студентов: ${selectedSubject!.studentCount}'),
            ],
          ],
        ),
      ),
    );
  }
}
