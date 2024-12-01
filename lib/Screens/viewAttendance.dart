import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({Key? key}) : super(key: key);

  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  String? studentId;
  List<Map<String, dynamic>> attendanceList = [];

  @override
  void initState() {
    super.initState();
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch student ID from Firestore
      /*final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();*/

      setState(() {
        studentId = user.uid; // Assuming 'studentID' field exists
      });

      // Fetch attendance data for the logged-in student
      final attendanceQuerySnapshot = await FirebaseFirestore.instance
          .collection('attendance_sessions')
          .where('attendanceStatus.$studentId', isNotEqualTo: null)
          .get();

      setState(() {
        attendanceList = attendanceQuerySnapshot.docs.map((doc) {
          return {
            'date': doc['date'],
            'startTime': doc['startTime'],
            'endTime': doc['endTime'],
            'attendanceStatus': doc['attendanceStatus'][studentId]
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Attendance"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: attendanceList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  var attendance = attendanceList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${attendance['date']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Start Time: ${attendance['startTime']}'),
                              Text('End Time: ${attendance['endTime']}'),
                            ],
                          ),
                          Icon(
                            attendance['attendanceStatus']
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: attendance['attendanceStatus']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
