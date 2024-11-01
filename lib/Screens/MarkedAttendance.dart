import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarkedAttendanceListPage extends StatefulWidget {
  @override
  _MarkedAttendanceListPageState createState() =>
      _MarkedAttendanceListPageState();
}

class _MarkedAttendanceListPageState extends State<MarkedAttendanceListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? teacherName;
  String? sessionId; // Unique ID for each attendance session
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  Future<void> _fetchTeacherName() async {
    String? teacherId = _auth.currentUser?.uid;

    if (teacherId != null) {
      DocumentSnapshot teacherSnapshot =
          await _firestore.collection('users').doc(teacherId).get();

      setState(() {
        teacherName = teacherSnapshot['name with initial'];
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        selectedTime = null; // Reset time if date is changed
        attendanceRecords = [];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        attendanceRecords = [];
      });
      _fetchAttendanceRecords();
    }
  }

  Future<void> _fetchAttendanceRecords() async {
    if (selectedDate == null || selectedTime == null || teacherName == null)
      return;

    sessionId =
        "${selectedDate!.toIso8601String()}_${selectedTime!.format(context)}_${teacherName}";

    try {
      DocumentSnapshot sessionSnapshot = await _firestore
          .collection('attendance_sessions')
          .doc(sessionId)
          .get();

      if (sessionSnapshot.exists) {
        Map<String, dynamic> data =
            sessionSnapshot.data() as Map<String, dynamic>;
        // Safely cast each entry in the attendanceStatus map to ensure it's a Map<String, bool>
        Map<String, bool> attendanceStatus =
            (data['attendanceStatus'] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value as bool));
        /*Map<String, bool> attendanceStatus =
            data['attendanceStatus'] as Map<String, bool>;*/

        setState(() {
          attendanceRecords = attendanceStatus.entries
              .map((entry) => {
                    'studentId': entry.key,
                    'studentName': data['studentName'] ?? 'Unknown',
                    'status': entry.value ? 'Present' : 'Absent',
                  })
              .toList();
        });
      } else {
        setState(() {
          attendanceRecords = [];
        });
      }
    } catch (error) {
      print("Error fetching attendance records: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Marked Attendance")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
              ),
              TextButton(
                onPressed:
                    selectedDate != null ? () => _selectTime(context) : null,
                child: Text(
                  selectedTime == null
                      ? 'Select Start Time'
                      : selectedTime!.format(context),
                ),
              ),
            ],
          ),
          Expanded(
            child: attendanceRecords.isEmpty
                ? Center(child: Text("No attendance records for this session."))
                : ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = attendanceRecords[index];
                      return ListTile(
                        title: Text("Student Name: ${record['studentName']}"),
                        subtitle: Text("Status: ${record['status']}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarkedAttendanceListPage extends StatefulWidget {
  @override
  _MarkedAttendanceListPageState createState() =>
      _MarkedAttendanceListPageState();
}

class _MarkedAttendanceListPageState extends State<MarkedAttendanceListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? selectedDate;
  String? teacherName;
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  Future<void> _fetchTeacherName() async {
    String? teacherId = _auth.currentUser?.uid;

    if (teacherId != null) {
      DocumentSnapshot teacherSnapshot =
          await _firestore.collection('users').doc(teacherId).get();

      setState(() {
        teacherName = teacherSnapshot[
            'name with initial']; // Assuming 'name' is the field for teacher's name
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAttendanceRecords();
    }
  }

  Future<void> _fetchAttendanceRecords() async {
    if (selectedDate == null || teacherName == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    QuerySnapshot snapshot = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: formattedDate)
        .where('teacherName',
            isEqualTo: teacherName) // Filter by teacher's name
        .get();

    setState(() {
      attendanceRecords = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Marked Attendance")),
      body: Column(
        children: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              selectedDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(selectedDate!),
            ),
          ),
          Expanded(
            child: attendanceRecords.isEmpty
                ? Center(child: Text("No attendance records for this date."))
                : ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = attendanceRecords[index];
                      return ListTile(
                        title: Text("Student Name: ${record['studentName']}"),
                        subtitle: Text("Status: ${record['status']}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}*/
