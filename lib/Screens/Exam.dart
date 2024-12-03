import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/components/successpage.dart';

class EnterMarksPage extends StatefulWidget {
  final Customuser user; // Logged-in teacher

  EnterMarksPage({required this.user});

  @override
  _EnterMarksPageState createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _examType = '';
  String _examDate = '';
  Map<String, String> _marks = {}; // Map to store student ID and marks
  List<Map<String, String>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // Fetch students with role "Student" from Firestore
  Future<void> _fetchStudents() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      setState(() {
        _students = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // Document ID
            'name': '${data['name with initial']}', // Full name
          };
        }).toList();
      });
    } catch (error) {
      print('Error fetching students: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch students')),
      );
    }
  }

  // Save entered marks to Firestore
  Future<void> _saveMarks() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        for (var entry in _marks.entries) {
          final studentId = entry.key;
          final marks = entry.value;

          final examMarks = ExamMarks(
            examDate: _examDate,
            examType: _examType,
            marks: {widget.user.subject!: marks},
            studentId: studentId,
            teacherName: '${widget.user.nameWithInitial} ',
            teacherSubject: widget.user.subject,
            stream: widget.user.stream,
            timestamp: Timestamp.now(),
          );

          await _firestore.collection('examMarks').add(examMarks.toFirestore());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marks saved successfully!')),
        );

        // Clear the form
        setState(() {
          _examType = '';
          _examDate = '';
          _marks.clear();
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubmissionSuccessPage()),
        );
      } catch (error) {
        print('Error saving marks: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save marks')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Marks for ${widget.user.subject}'),
      ),
      body: _students.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Exam Type field
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Exam Type'),
                      onSaved: (value) => _examType = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter exam type' : null,
                    ),

                    // Exam Date field
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Exam Date'),
                      onSaved: (value) => _examDate = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter exam date' : null,
                    ),

                    SizedBox(height: 20),

                    // List of students with marks fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _students.map((student) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(student['name']!,
                                    style: TextStyle(fontSize: 16)),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Marks'),
                                  onSaved: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      _marks[student['id']!] = value;
                                    }
                                  },
                                  validator: (value) =>
                                      value!.isEmpty ? 'Enter marks' : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    // Save button
                    ElevatedButton(
                      onPressed: _saveMarks,
                      child: Text('Save Marks'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
