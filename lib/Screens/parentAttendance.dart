import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String childName; // Pass childName instead of childId

  AttendanceDetailPage({required this.childName});

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  late Stream<QuerySnapshot> _attendanceStream;
  late Future<String> _childIdFuture; // Store Future for childId

  @override
  void initState() {
    super.initState();
    // Query to get the childId based on the childName
    _childIdFuture = _getChildId(widget.childName);
  }

  // Method to fetch child ID based on childName
  Future<String> _getChildId(String childName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users') // Assuming the users collection has child details
        .where('name with initial',
            isEqualTo: childName) // Match the name to get the ID
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // The document ID is the child ID
    } else {
      return ''; // Return an empty string if no child found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details for ${widget.childName}'),
      ),
      body: FutureBuilder<String>(
        future: _childIdFuture, // Fetch the childId asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching child ID'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Child not found.'));
          }

          final childId = snapshot.data!;

          // Now that we have the childId, fetch the attendance data
          _attendanceStream = FirebaseFirestore.instance
              .collection('attendance_sessions')
              .where('attendanceStatus.$childId', isNotEqualTo: null)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: _attendanceStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong!'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No attendance data found.'));
              }

              final attendanceData = snapshot.data!.docs;

              return ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final doc = attendanceData[index];
                  final date = doc['date'] ?? 'N/A';
                  final attendanceStatus = doc['attendanceStatus'][childId];

                  return ListTile(
                    title: Text('Date: $date'),
                    subtitle: Text(
                        'Status: ${attendanceStatus ? 'Present' : 'Absent'}'),
                    trailing: Icon(
                      attendanceStatus ? Icons.check : Icons.close,
                      color: attendanceStatus ? Colors.green : Colors.red,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
