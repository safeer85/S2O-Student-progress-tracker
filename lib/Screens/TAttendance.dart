import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, bool> attendanceStatus = {};
  List<Map<String, dynamic>> students = [];
  String teacherName = "Unknown"; // Placeholder for the teacher's name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
    _fetchStudents();
  }

  Future<void> _fetchTeacherName() async {
    try {
      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      // Placeholder for teacher UID
      DocumentSnapshot teacherSnapshot =
          await _firestore.collection('users').doc(currentUserUid).get();

      setState(() {
        teacherName = teacherSnapshot['name with initial'] ?? 'Unknown';
      });
    } catch (error) {
      print("Error fetching teacher name: $error");
    }
  }

  Future<void> _fetchStudents() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      setState(() {
        students = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name with initial'] ?? 'Unknown',
          };
        }).toList();

        // Initialize attendance status for each student
        for (var student in students) {
          attendanceStatus[student['id']!] = false;
        }
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching students: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select date and time")));
      return;
    }

    for (var student in students) {
      bool isPresent = attendanceStatus[student['id']!] ?? false;
      await _firestore.collection('attendance').add({
        'studentId': student['id'],
        'studentName': student['name'],
        'teacherName': teacherName,
        // Store teacher's name
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'time': selectedTime!.format(context),
        'status': isPresent ? 'Present' : 'Absent',
      });
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Attendance saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Take Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(selectedTime == null
                      ? 'Select Time'
                      : selectedTime!.format(context)),
                ),
              ],
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text(student['name']!),
                          trailing: Checkbox(
                            value: attendanceStatus[student['id']],
                            onChanged: (bool? value) {
                              setState(() {
                                attendanceStatus[student['id']!] = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: _saveAttendance,
              child: Text("Save Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, bool> attendanceStatus = {};
  List<Map<String, dynamic>> students = [];
  bool isLoading = true; // Flag to show loading state

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      setState(() {
        students = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name with initial'] ?? 'Unknown', // Check field exists
          };
        }).toList();

        // Initialize attendance status for each student
        for (var student in students) {
          attendanceStatus[student['id']] =
              false; // Default attendance to absent
        }
        isLoading = false; // End loading once data is fetched
      });
    } catch (error) {
      print("Error fetching students: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select date and time")));
      return;
    }

    for (var student in students) {
      bool isPresent = attendanceStatus[student['id']!] ?? false;
      await _firestore.collection('attendance').add({
        'studentId': student['id'],
        'name with initial': student['name'],
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'time': selectedTime!.format(context),
        'status': isPresent ? 'Present' : 'Absent',
      });
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Attendance saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Take Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(selectedTime == null
                      ? 'Select Time'
                      : selectedTime!.format(context)),
                ),
              ],
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text(student['name']!),
                          trailing: Checkbox(
                            value: attendanceStatus[student['id']],
                            onChanged: (bool? value) {
                              setState(() {
                                attendanceStatus[student['id']] = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: _saveAttendance,
              child: Text("Save Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}*/
