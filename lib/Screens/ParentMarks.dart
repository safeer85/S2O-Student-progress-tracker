import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViewChildMarksPage extends StatefulWidget {
  final String childName;

  ViewChildMarksPage({required this.childName});

  @override
  _ViewChildMarksPageState createState() => _ViewChildMarksPageState();
}

class _ViewChildMarksPageState extends State<ViewChildMarksPage> {
  late Stream<QuerySnapshot> _marksStream;
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
        title: Text('Marks Details - ${widget.childName}'),
        backgroundColor: const Color.fromARGB(255, 44, 100, 183),
      ),
      body: FutureBuilder<String>(
        future: _childIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching child ID.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Child not found.'));
          }

          final childId = snapshot.data!;

          _marksStream = FirebaseFirestore.instance
              .collection('examMarks')
              .where('studentId', isEqualTo: childId)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: _marksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading marks data.'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No marks data available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final marksData = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: marksData.length,
                itemBuilder: (context, index) {
                  final doc = marksData[index];
                  final examDateStr = doc['examDate'] ?? 'N/A';
                  DateTime? examDate;

                  // Try to parse the date string with known formats
                  if (examDateStr != 'N/A') {
                    try {
                      // Adjust the pattern to match your Firestore date format
                      examDate = DateFormat('yyyy-MM-dd').parse(examDateStr);
                    } catch (e) {
                      try {
                        // Fallback to another common format
                        examDate = DateFormat('MM/dd/yyyy').parse(examDateStr);
                      } catch (e) {
                        examDate = null; // Handle parsing errors
                      }
                    }
                  }

                  final formattedDate = examDate != null
                      ? DateFormat('dd MMM yyyy').format(examDate)
                      : 'Invalid date';
                  final examType = doc['examType'] ?? 'N/A';
                  final marks = doc['marks'] as Map<String, dynamic>? ?? {};

                  final teacherName = doc['teacherName'] ?? 'N/A';
                  final teacherSubject = doc['teacherSubject'] ?? 'N/A';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exam: $examType',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date: $formattedDate',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                          Text(
                            'Teacher: $teacherName ($teacherSubject)',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Marks:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...marks.keys.map(
                            (subject) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.book,
                                    color: Colors.teal,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '$subject: ${marks[subject]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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






















/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewChildMarksPage extends StatefulWidget {
  final String childName; // Pass childName instead of childId

  ViewChildMarksPage({required this.childName});

  @override
  _ViewChildMarksPageState createState() => _ViewChildMarksPageState();
}

class _ViewChildMarksPageState extends State<ViewChildMarksPage> {
  late Stream<QuerySnapshot> _marksStream;
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
        title: Text('Marks Details for ${widget.childName}'),
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

          // Now that we have the childId, fetch the marks data
          _marksStream = FirebaseFirestore.instance
              .collection('examMarks')
              .where('studentId',
                  isEqualTo: childId) // Fetch marks by studentId (childId)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: _marksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong!'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No marks data found.'));
              }

              final marksData = snapshot.data!.docs;

              return ListView.builder(
                itemCount: marksData.length,
                itemBuilder: (context, index) {
                  final doc = marksData[index];
                  final examDate = doc['examDate'] ?? 'N/A';
                  final examType = doc['examType'] ?? 'N/A';
                  final marks = doc['marks'] ?? {};
                  final stream = doc['stream'] ?? 'N/A';
                  final teacherName = doc['teacherName'] ?? 'N/A';
                  final teacherSubject = doc['teacherSubject'] ?? 'N/A';

                  return ListTile(
                    title: Text('Exam: $examType on $examDate'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stream: $stream'),
                        Text('Teacher: $teacherName ($teacherSubject)'),
                        for (var subject in marks.keys)
                          Text(
                              '$subject: ${marks[subject]}'), // Display marks for each subject
                      ],
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
}*/
