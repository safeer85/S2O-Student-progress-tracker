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
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Map<String, bool> attendanceStatus = {};
  List<Map<String, dynamic>> students = [];
  String teacherName = "Unknown"; // Placeholder for the teacher's name
  bool isLoading = true;
  bool isWithinTimeWindow = true;
  String? sessionId; // Unique identifier for each attendance session

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
    _fetchStudents();
  }

  Future<void> _fetchTeacherName() async {
    try {
      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
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
        _loadExistingAttendance();
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
        _loadExistingAttendance();
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (selectedDate == null || startTime == null) return;

    sessionId =
        "${selectedDate!.toIso8601String()}_${startTime!.format(context)}_${teacherName}";

    try {
      DocumentSnapshot sessionSnapshot = await _firestore
          .collection('attendance_sessions')
          .doc(sessionId)
          .get();

      if (sessionSnapshot.exists) {
        // Load existing attendance data
        Map<String, dynamic> data =
            sessionSnapshot.data() as Map<String, dynamic>;
        Map<String, bool> loadedStatus = {};
        data['attendanceStatus'].forEach((studentId, status) {
          loadedStatus[studentId] = status as bool;
        });

        setState(() {
          attendanceStatus = loadedStatus;
        });
      }
    } catch (error) {
      print("Error loading existing attendance: $error");
    }
  }

  Future<void> _saveAttendance() async {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select date, start time, and end time")));
      return;
    }

    DateTime now = DateTime.now();
    DateTime endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (now.isAfter(endDateTime)) {
      setState(() {
        isWithinTimeWindow = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cannot edit attendance after end time")));
      return;
    }

    sessionId =
        "${selectedDate!.toIso8601String()}_${startTime!.format(context)}_${teacherName}";

    try {
      await _firestore.collection('attendance_sessions').doc(sessionId).set({
        'teacherName': teacherName,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'startTime': startTime!.format(context),
        'endTime': endTime!.format(context),
        'attendanceStatus': attendanceStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance saved successfully")));
    } catch (error) {
      print("Error saving attendance: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance"),
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
                  onPressed: () => _selectStartTime(context),
                  child: Text(startTime == null
                      ? 'Select Start Time'
                      : startTime!.format(context)),
                ),
                TextButton(
                  onPressed: () => _selectEndTime(context),
                  child: Text(endTime == null
                      ? 'Select End Time'
                      : endTime!.format(context)),
                ),
              ],
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text(student['name']!),
                          trailing: Checkbox(
                            value: attendanceStatus[student['id']],
                            onChanged: isWithinTimeWindow
                                ? (bool? value) {
                                    setState(() {
                                      attendanceStatus[student['id']] = value!;
                                    });
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: isWithinTimeWindow ? _saveAttendance : null,
              child: const Text("Save Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
