import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firebase_service.dart';
import '../shared/widgets.dart';

class GradeEditDialog extends StatefulWidget {
  final Student student;
  final String date;
  final String currentScore;
  final Function(String newScore) onSave;

  const GradeEditDialog({
    super.key,
    required this.student,
    required this.date,
    required this.currentScore,
    required this.onSave,
  });

  @override
  GradeEditDialogState createState() => GradeEditDialogState();
}

class GradeEditDialogState extends State<GradeEditDialog> {
  late TextEditingController scoreController;
  bool isAbsent = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.currentScore != 'Н') {
      scoreController = TextEditingController(text: widget.currentScore);
    } else {
      scoreController = TextEditingController(text: "");
      isAbsent = true;
    }
    focus();
  }

  void focus() {
    if (!isAbsent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  @override
  void dispose() {
    scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth =
        screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.8;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Изменить оценку',
              style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Студент: ${widget.student.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Дата: ${widget.date}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              AnimatedOpacity(
                opacity: isAbsent ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: isAbsent ? 0 : 68,
                  child: Visibility(
                    visible: !isAbsent,
                    child: buildTextInput(
                      scoreController,
                      "Введите новую оценку",
                      keyboardType: TextInputType.visiblePassword,
                      context: context,
                      activeIcon: scoreController.text != '',
                      enabled: !isAbsent,
                      iconType: scoreController.text == '' ? 'edit' : 'delete',
                      currentFocus: _focusNode,
                      onIconPressed:() => {
                        scoreController.text = '',
                        FocusScope.of(context).unfocus()
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () {
                  setState(() {
                    isAbsent = !isAbsent;
                    if (isAbsent) {
                      scoreController.clear();
                    } else {
                      focus();
                    }
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isAbsent,
                        onChanged: (bool? value) {
                          setState(() {
                            isAbsent = value ?? false;
                            if (isAbsent) {
                              scoreController.clear();
                            } else {
                              focus();
                            }
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Отсутствовал(-а)",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isAbsent
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Отменить'),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            SizedBox(width: screenWidth > 600 ? 120 : 8),
            Flexible(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _saveGrade,
                  child: Text('Сохранить'),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _saveGrade() {
    String newScore = isAbsent ? 'Н' : scoreController.text;
    widget.onSave(newScore);
    Navigator.of(context).pop();
  }
}
