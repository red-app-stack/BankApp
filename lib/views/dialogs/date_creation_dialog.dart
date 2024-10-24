import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/widgets.dart';


class DateCreationDialog extends StatefulWidget {
  final String? initialDate;
  final String? initialDescription;
  final String? initialType;
  final Function(String date, String description, String type) onSave;

  const DateCreationDialog({
    super.key,
    this.initialDate,
    this.initialDescription,
    this.initialType,
    required this.onSave,
  });

  @override
  DateCreationDialogState createState() => DateCreationDialogState();
}

class DateCreationDialogState extends State<DateCreationDialog> {
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  String _selectedType = 'Обычная оценка';
  final List<String> _gradeTypes = [
    'Обычная оценка',
    'Средняя оценка',
    'Оценка модуля'
  ];
  
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
        text: widget.initialDate ??
            DateFormat('dd.MM.yyyy').format(DateTime.now()));
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _dateFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _showDatePicker() async {
    FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        locale: const Locale("ru", "RU"),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            child: child!,
          );
        });
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.8;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Изменить дату',
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
            children: [
              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _gradeTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Выберите тип',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                isExpanded: true,
              ),
              SizedBox(height: 16),
              // Date Input using buildTextInput
              buildTextInput(
                _dateController,
                'Выберите дату',
                iconType: 'calendar',
                context: context,
                enabled: true,
                currentFocus: _dateFocusNode,
                nextFocus: _descriptionFocusNode,
                onIconPressed: _showDatePicker,
              ),
              buildTextInput(
                _descriptionController,
                'Введите описание',
                iconType: 'edit',
                context: context,
                enabled: true,
                currentFocus: _descriptionFocusNode,
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
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    widget.onSave(_dateController.text,
                        _descriptionController.text, _selectedType);
                    Navigator.of(context).pop();
                  },
                  child: Text(_dateController.text.isEmpty ? 'Удалить' : 'Сохранить'),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}