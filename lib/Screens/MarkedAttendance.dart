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
}
