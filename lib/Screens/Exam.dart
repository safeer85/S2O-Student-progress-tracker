import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/components/successpage.dart';

class EnterMarksPage extends StatefulWidget {
  final Customuser user;

  EnterMarksPage({required this.user});

  @override
  _EnterMarksPageState createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _examType = '';
  DateTime? _examDate;
  Map<String, String> _marks = {};
  //List<Map<String, String>> _students = [];
  List<Map<String, dynamic>> _students = [];

  int? _selectedBatch; // Selected batch year

  @override
  void initState() {
    super.initState();
  }

  // Fetch students based on the selected batch

  Future<void> _fetchStudents() async {
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a batch first')),
      );
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('batch',
              isEqualTo: _selectedBatch.toString()) // Filter by batch
          .get();

      setState(() {
        _students = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name with initial'],
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
    if (_formKey.currentState!.validate() && _selectedBatch != null) {
      _formKey.currentState!.save();

      try {
        for (var entry in _marks.entries) {
          final studentId = entry.key;
          final marks = entry.value;

          final examMarks = ExamMarks(
            examDate: DateFormat('yyyy-MM-dd').format(_examDate!),
            examType: _examType,
            marks: {widget.user.subject!: marks},
            studentId: studentId,
            teacherName: widget.user.nameWithInitial,
            teacherSubject: widget.user.subject,
            stream: widget.user.stream,
            batch: _selectedBatch.toString(),
            timestamp: Timestamp.now(),
          );

          await _firestore.collection('examMarks').add(examMarks.toFirestore());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marks saved successfully!')),
        );

        setState(() {
          _examType = '';
          _examDate = null;
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form')),
      );
    }
  }

  // Show calendar date picker
  Future<void> _selectExamDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _examDate = selectedDate;
      });
    }
  }

  // Batch selection dialog
  Future<void> _selectBatch(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final List<int> availableBatches =
        List.generate(10, (index) => currentYear + index); // Last 10 years

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select Batch Year'),
          children: availableBatches.map((year) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, year),
              child: Text(year.toString()),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedBatch = selected;
        _students.clear();
      });
      await _fetchStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Redirect to login if no user is logged in
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Marks for ${widget.user.subject}'),
        backgroundColor: const Color.fromARGB(
            255, 44, 100, 183), // Dark blue background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Select batch button
              ElevatedButton(
                onPressed: () => _selectBatch(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 44, 100, 183), // Dark blue button
                  foregroundColor: Colors.white, // White text color
                ),
                child: Text(
                  _selectedBatch == null
                      ? 'Select Batch'
                      : 'Selected Batch: $_selectedBatch',
                ),
              ),

              SizedBox(height: 20),

              // Exam Type field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Exam Type',
                  labelStyle: TextStyle(
                      color: const Color.fromARGB(
                          255, 44, 100, 183)), // Dark blue label color
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(
                            255, 44, 100, 183)), // Dark blue border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(
                            255, 44, 100, 183)), // Dark blue border color
                  ),
                ),
                onSaved: (value) => _examType = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter exam type' : null,
              ),

              SizedBox(height: 20),

              // Exam Date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _examDate == null
                          ? 'No date selected'
                          : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_examDate!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectExamDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 44, 100, 183), // Dark blue button
                      foregroundColor: Colors.white, // White text color
                    ),
                    child: Text('Select Date'),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // List of students with marks fields
              _students.isEmpty
                  ? Text('No students found for the selected batch')
                  : Column(
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
                                  decoration: InputDecoration(
                                    labelText: 'Marks',
                                    labelStyle: TextStyle(
                                        color: const Color.fromARGB(255, 44,
                                            100, 183)), // Dark blue label color
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255,
                                              44,
                                              100,
                                              183)), // Dark blue border color
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255,
                                              44,
                                              100,
                                              183)), // Dark blue border color
                                    ),
                                  ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 44, 100, 183), // Dark blue button
                  foregroundColor: Colors.white, // White text color
                ),
                child: Text('Save Marks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date parsing and formatting
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
  DateTime? _examDate; // Use DateTime for better handling
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
            examDate:
                DateFormat('yyyy-MM-dd').format(_examDate!), // Format date
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
          _examDate = null;
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

  // Show calendar date picker
  Future<void> _selectExamDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _examDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Marks for ${widget.user.subject}'),
        backgroundColor: Colors.blueAccent,
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
                      decoration: InputDecoration(
                        labelText: 'Exam Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      onSaved: (value) => _examType = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter exam type' : null,
                    ),

                    SizedBox(height: 20),

                    // Exam Date picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _examDate == null
                                ? 'No date selected'
                                : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_examDate!)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          onPressed: () => _selectExamDate(context),
                          child: Text('Select Date'),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // List of students with marks fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _students.map((student) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      student['name']!,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Marks',
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                      ),
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
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    // Save button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                      ),
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
*/



/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date parsing and formatting
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
  DateTime? _examDate; // Use DateTime for better handling
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
            examDate:
                DateFormat('yyyy-MM-dd').format(_examDate!), // Format date
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
          _examDate = null;
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

  // Show calendar date picker
  Future<void> _selectExamDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _examDate = selectedDate;
      });
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

                    SizedBox(height: 20),

                    // Exam Date picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _examDate == null
                                ? 'No date selected'
                                : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_examDate!)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _selectExamDate(context),
                          child: Text('Select Date'),
                        ),
                      ],
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
}*/





