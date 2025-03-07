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
  Map<String, List<Map<String, dynamic>>> attendanceSessionsByBatch = {};

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
            teacherName = teacherSnapshot['name with initial'];
          });
          _fetchAttendanceSessions();
        }
      } catch (error) {
        print("Error fetching teacher name: $error");
      }
    }
  }

  Future<void> _fetchAttendanceSessions() async {
    if (teacherName == null) return;

    try {
      QuerySnapshot sessionSnapshot = await _firestore
          .collection('attendance_sessions')
          .where('teacherName', isEqualTo: teacherName)
          .get();

      Map<String, List<Map<String, dynamic>>> tempSessionsByBatch = {};

      for (var doc in sessionSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final batch = data['batch'] ?? 'Unknown';

        final sessionData = {
          'sessionId': doc.id,
          'date': data['date'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'attendanceStatus': data['attendanceStatus'],
          'batch': batch,
        };

        if (!tempSessionsByBatch.containsKey(batch)) {
          tempSessionsByBatch[batch] = [];
        }
        tempSessionsByBatch[batch]!.add(sessionData);
      }

      setState(() {
        attendanceSessionsByBatch = tempSessionsByBatch;
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
        title: const Text("Attendance Sessions"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: attendanceSessionsByBatch.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading attendance sessions..."),
                ],
              ),
            )
          : ListView(
              children: attendanceSessionsByBatch.keys.map((batch) {
                final sessions = attendanceSessionsByBatch[batch]!;
                return ExpansionTile(
                  title: Text(
                    "Batch: $batch",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: sessions.map((session) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          "${session['date']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                                    final record =
                                        attendanceRecords[recordIndex];
                                    return ListTile(
                                      title: Text(
                                          "Student Name: ${record['studentName']}"),
                                      subtitle:
                                          Text("Status: ${record['status']}"),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}






/*import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> attendanceSessions = [];

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
            teacherName = teacherSnapshot['name with initial'];
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
    // Fetch sessions filtered only by teacherName
    QuerySnapshot sessionSnapshot = await _firestore
        .collection('attendance_sessions')
        .where('teacherName', isEqualTo: teacherName)
        .get();

    List<Map<String, dynamic>> tempSessions = [];

    for (var doc in sessionSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['batch'] == selectedBatch) { // Apply batch filtering locally
        tempSessions.add({
          'sessionId': doc.id,
          'date': data['date'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'attendanceStatus': data['attendanceStatus'],
          'batch': data['batch'],
        });
      }
    }

    setState(() {
      attendanceSessions = tempSessions;
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
      appBar: AppBar(
        title: const Text("Attendance Sessions"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: attendanceSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading attendance sessions..."),
                ],
              ),
            )
          : ListView.builder(
              itemCount: attendanceSessions.length,
              itemBuilder: (context, index) {
                final session = attendanceSessions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "${session['date']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Time: ${session['startTime']} - ${session['endTime']}"),
                        Text("Batch: ${session['batch']}"), // Display batch
                      ],
                    ),
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
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        "Student Name: ${record['studentName']}"),
                                    subtitle:
                                        Text("Status: ${record['status']}"),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}*/




/*import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> attendanceSessions = [];

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
            teacherName = teacherSnapshot['name with initial'];
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
        attendanceSessions = tempSessions;
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
      appBar: AppBar(
        title: const Text("Attendance Sessions"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: attendanceSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading attendance sessions..."),
                ],
              ),
            )
          : ListView.builder(
              itemCount: attendanceSessions.length,
              itemBuilder: (context, index) {
                final session = attendanceSessions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "${session['date']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        "Student Name: ${record['studentName']}"),
                                    subtitle:
                                        Text("Status: ${record['status']}"),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}*/






/*import 'package:flutter/material.dart';
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
}*/
 

 /*Future<void> _fetchAttendanceSessions() async {
    if (teacherName == null) return;

    try {
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
          'batch': doc['batch'], // Fetch batch (year)
          'attendanceStatus': doc['attendanceStatus'],
        });
      }

      setState(() {
        attendanceSessions = tempSessions;
      });
    } catch (error) {
      print("Error fetching attendance sessions: $error");
    }
  }*/
