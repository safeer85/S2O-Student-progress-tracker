import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String childName;

  AttendanceDetailPage({required this.childName});

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  late Future<String> _childIdFuture;

  @override
  void initState() {
    super.initState();
    _childIdFuture = _getChildId(widget.childName);
  }

  Future<String> _getChildId(String childName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name with initial', isEqualTo: childName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return ''; // Return an empty string if no child is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<String>(
        future: _childIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error fetching child ID');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState('Child not found.');
          }

          final childId = snapshot.data!;

          final attendanceStream = FirebaseFirestore.instance
              .collection('attendance_sessions')
              .where('attendanceStatus.$childId', isNotEqualTo: null)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: attendanceStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState('Something went wrong!');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final attendanceData = snapshot.data!.docs.where((doc) {
                final attendanceStatus =
                    doc['attendanceStatus'] as Map<String, dynamic>?;
                return attendanceStatus != null &&
                    attendanceStatus.containsKey(childId);
              }).toList();

              if (attendanceData.isEmpty) {
                return _buildEmptyState(); // Show "No attendance data available."
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final doc = attendanceData[index];
                  final date = doc['date'] ?? 'N/A';
                  final attendanceStatus = doc['attendanceStatus'][childId];
                  final formattedDate = DateFormat('yyyy-MM-dd').format(
                    DateTime.parse(date),
                  );

                  return _buildAttendanceCard(
                    date: formattedDate,
                    status: attendanceStatus,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        ' ${widget.childName}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() {
              _childIdFuture = _getChildId(widget.childName);
            });
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceCard({required String date, required bool status}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: status ? Colors.green : Colors.red,
          child: Icon(
            status ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Date: $date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Status: ${status ? 'Present' : 'Absent'}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance data found.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String childName;

  AttendanceDetailPage({required this.childName});

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  late Future<String> _childIdFuture;

  @override
  void initState() {
    super.initState();
    _childIdFuture = _getChildId(widget.childName);
  }

  Future<String> _getChildId(String childName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name with initial', isEqualTo: childName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<String>(
        future: _childIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error fetching child ID');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState('Child not found.');
          }

          final childId = snapshot.data!;

          final attendanceStream = FirebaseFirestore.instance
              .collection('attendance_sessions')
              .where('attendanceStatus.$childId', isNotEqualTo: null)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: attendanceStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState('Something went wrong!');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final attendanceData = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final doc = attendanceData[index];
                  final date = doc['date'] ?? 'N/A';
                  final attendanceStatus = doc['attendanceStatus'][childId];
                  final formattedDate = DateFormat('yyyy-MM-dd').format(
                    DateTime.parse(date),
                  );

                  return _buildAttendanceCard(
                    date: formattedDate,
                    status: attendanceStatus,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 4,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        ' ${widget.childName}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() {
              _childIdFuture = _getChildId(widget.childName);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            _showInfoDialog(context);
          },
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attendance Information'),
          content: const Text(
              'This page displays the attendance details for the selected child. '
              'Use the refresh button to update the data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceCard({required String date, required bool status}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: status ? Colors.green : Colors.red,
          child: Icon(
            status ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Date: $date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Status: ${status ? 'Present' : 'Absent'}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance data found.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}*/
