import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarkedAttendanceListPage extends StatefulWidget {
  @override
  _MarkedAttendanceListPageState createState() =>
      _MarkedAttendanceListPageState();
}

class _MarkedAttendanceListPageState extends State<MarkedAttendanceListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? teacherName;
  List<Map<String, dynamic>> attendanceSessions =
      []; // To hold attendance sessions

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  Future<void> _fetchTeacherName() async {
    String? teacherId = _auth.currentUser?.uid;

    if (teacherId != null) {
      try {
        DocumentSnapshot teacherSnapshot =
            await _firestore.collection('users').doc(teacherId).get();

        if (teacherSnapshot.exists) {
          setState(() {
            teacherName = teacherSnapshot[
                'name with initial']; // Fetch the teacher's name
          });
          _fetchAttendanceSessions(); // Fetch attendance sessions after getting the name
        }
      } catch (error) {
        print("Error fetching teacher name: $error");
      }
    }
  }

  Future<void> _fetchAttendanceSessions() async {
    if (teacherName == null) return;

    try {
      // Fetch all attendance sessions for the logged-in teacher using their name
      QuerySnapshot sessionSnapshot = await _firestore
          .collection('attendance_sessions')
          .where('teacherName', isEqualTo: teacherName)
          .get();

      List<Map<String, dynamic>> tempSessions = [];

      for (var doc in sessionSnapshot.docs) {
        tempSessions.add({
          'sessionId': doc.id,
          'date': doc['date'],
          'startTime': doc['startTime'],
          'endTime': doc['endTime'],
          'attendanceStatus': doc['attendanceStatus'],
        });
      }

      setState(() {
        attendanceSessions = tempSessions; // Update state with sessions
      });
    } catch (error) {
      print("Error fetching attendance sessions: $error");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceRecords(
      Map<String, dynamic> session) async {
    List<Map<String, dynamic>> tempRecords = [];
    Map<String, dynamic> attendanceStatus = session['attendanceStatus'];

    for (var entry in attendanceStatus.entries) {
      String studentId = entry.key;
      bool status = entry.value;

      // Fetch student name from Users collection using studentId
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(studentId).get();

      if (userSnapshot.exists) {
        String studentName = (userSnapshot.data()
                as Map<String, dynamic>)['name with initial'] ??
            'Unknown';

        tempRecords.add({
          'studentId': studentId,
          'studentName': studentName,
          'status': status ? 'Present' : 'Absent',
        });
      } else {
        // If user does not exist, add with 'Unknown' name
        tempRecords.add({
          'studentId': studentId,
          'studentName': 'Unknown',
          'status': status ? 'Present' : 'Absent',
        });
      }
    }

    return tempRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Marked Attendance")),
      body: attendanceSessions.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.builder(
              itemCount: attendanceSessions.length,
              itemBuilder: (context, index) {
                final session = attendanceSessions[index];
                return ExpansionTile(
                  title: Text("${session['date']}"),
                  subtitle: Text(
                      "Time: ${session['startTime']} - ${session['endTime']}"),
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchAttendanceRecords(session),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Loading attendance records..."),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Error fetching records"),
                          );
                        } else {
                          final attendanceRecords = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: attendanceRecords.length,
                            itemBuilder: (context, recordIndex) {
                              final record = attendanceRecords[recordIndex];
                              return ListTile(
                                title: Text(
                                    "Student Name: ${record['studentName']}"),
                                subtitle: Text("Status: ${record['status']}"),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
