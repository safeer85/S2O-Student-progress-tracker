import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamMarksEntryPage extends StatefulWidget {
  final String teacherName;
  final String teacherSubject;

  const ExamMarksEntryPage({
    Key? key,
    required this.teacherName,
    required this.teacherSubject,
  }) : super(key: key);

  @override
  _ExamMarksEntryPageState createState() => _ExamMarksEntryPageState();
}

class _ExamMarksEntryPageState extends State<ExamMarksEntryPage> {
  String? selectedStudent;
  String? studentStream;
  List<Map<String, dynamic>> students = [];
  final Map<String, TextEditingController> subjectControllers = {
    'Biology': TextEditingController(),
    'Chemistry': TextEditingController(),
    'Physics': TextEditingController(),
    'Combined Mathematics': TextEditingController(),
  };

  // New controllers for Exam Type and Exam Date
  final TextEditingController examTypeController = TextEditingController();
  final TextEditingController examDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    // Fetch students with role 'student' and store them in the students list
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .get();

    setState(() {
      students = studentsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name with initial'],
                'stream':
                    doc['stream'], // assuming each student has a 'stream' field
              })
          .toList();
    });
  }

  void _saveMarks() async {
    if (selectedStudent == null || studentStream == null) {
      // Check if a student is selected and all marks are entered
      if (subjectControllers[widget.teacherSubject]?.text.isEmpty ?? true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all student marks!")),
        );
        return;
      }
    }

    final data = {
      'studentId': selectedStudent,
      'teacherName': widget.teacherName,
      'teacherSubject': widget.teacherSubject, // Save teacher's subject
      'stream': studentStream,
      'marks': {
        widget.teacherSubject: subjectControllers[widget.teacherSubject]?.text,
      },
      'examType': examTypeController.text, // Save Exam Type
      'examDate': examDateController.text, // Save Exam Date
      'timestamp': Timestamp.now(),
    };

    // Save the marks to Firestore
    await FirebaseFirestore.instance.collection('examMarks').add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marks saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Exam Marks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Student'),
            // Display students in a list
            ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isSelected = selectedStudent == student['id'];

                return ListTile(
                  title: Text(student['name']),
                  tileColor:
                      isSelected ? Colors.blueAccent.withOpacity(0.3) : null,
                  onTap: () {
                    setState(() {
                      selectedStudent = student['id'];
                      studentStream = student['stream'];
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Only show the subject field for the teacher's assigned subject
            _buildSubjectField(widget.teacherSubject),
            const SizedBox(height: 20),

            // Exam Type input
            TextFormField(
              controller: examTypeController,
              decoration: const InputDecoration(
                labelText: 'Exam Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Exam Date input
            // Exam Date input with Date Picker
            TextFormField(
              controller: examDateController,
              decoration: const InputDecoration(
                labelText: 'Exam Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
                suffixIcon:
                    Icon(Icons.calendar_today), // Calendar icon for clarity
              ),
              readOnly:
                  true, // Make the field read-only to prevent manual editing
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), // Earliest selectable date
                  lastDate: DateTime(2100), // Latest selectable date
                );

                if (pickedDate != null) {
                  // Format the date as YYYY-MM-DD and set it in the controller
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  examDateController.text = formattedDate;
                }
              },
            ),

            /* TextFormField(
              controller: examDateController,
              decoration: const InputDecoration(
                labelText: 'Exam Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),*/
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMarks,
              child: const Text('Submit Marks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectField(String subject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('$subject Marks'),
        TextFormField(
          controller: subjectControllers[subject],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '$subject Marks',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
