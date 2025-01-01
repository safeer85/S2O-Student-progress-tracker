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
  bool isLoading = true; // Track loading state
  String? errorMessage; // Track errors or absence of data

  @override
  void initState() {
    super.initState();
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch student ID
        setState(() {
          studentId = user.uid;
        });

        // Query attendance data
        final attendanceQuerySnapshot = await FirebaseFirestore.instance
            .collection('attendance_sessions')
            .where('attendanceStatus.$studentId', isNotEqualTo: null)
            .get();

        if (attendanceQuerySnapshot.docs.isEmpty) {
          // No attendance records found
          setState(() {
            isLoading = false;
            errorMessage = "No attendance records found.";
          });
          return;
        }

        // Process attendance data
        setState(() {
          attendanceList = attendanceQuerySnapshot.docs.map((doc) {
            return {
              'date': doc['date'] ?? 'Unknown Date',
              'startTime': doc['startTime'] ?? 'Unknown Start Time',
              'endTime': doc['endTime'] ?? 'Unknown End Time',
              'attendanceStatus': doc['attendanceStatus'][studentId] ?? false,
            };
          }).toList();
          isLoading = false;
        });
      } catch (e) {
        // Handle errors
        setState(() {
          isLoading = false;
          errorMessage = "An error occurred: ${e.toString()}";
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "User not logged in.";
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : attendanceList.isEmpty
                    ? const Center(
                        child: Text(
                          "No attendance records available.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: attendanceList.length,
                        itemBuilder: (context, index) {
                          var attendance = attendanceList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date: ${attendance['date']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Start Time: ${attendance['startTime']}'),
                                      Text(
                                          'End Time: ${attendance['endTime']}'),
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
