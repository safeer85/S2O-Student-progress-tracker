import 'package:flutter/material.dart';
import 'package:s20/Classes/Marks.dart';

class EditMarksDialog extends StatefulWidget {
  final ExamMarks mark;

  EditMarksDialog({required this.mark});

  @override
  _EditMarksDialogState createState() => _EditMarksDialogState();
}

class _EditMarksDialogState extends State<EditMarksDialog> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    widget.mark.marks?.forEach((subject, mark) {
      _controllers[subject] = TextEditingController(text: mark);
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Marks'),
      content: SingleChildScrollView(
        child: Column(
          children: _controllers.entries.map((entry) {
            return TextFormField(
              controller: entry.value,
              decoration: InputDecoration(labelText: '${entry.key} Marks'),
              keyboardType: TextInputType.number,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedMarks = _controllers.map((subject, controller) =>
                MapEntry(subject, controller.text.trim()));
            Navigator.pop(context, updatedMarks);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
