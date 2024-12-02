import 'package:cloud_firestore/cloud_firestore.dart';
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
}





/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewMarksPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the logged-in parent's UID and child's name
  Future<String?> _getChildName(String parentId) async {
    DocumentSnapshot parentDoc =
        await _firestore.collection('users').doc(parentId).get();

    if (parentDoc.exists && parentDoc['childName'] != null) {
      return parentDoc[
          'childName']; // Assuming the parent's document contains a field 'childName'
    }
    return null;
  }

  // Fetch the student's UID based on the child's name
  Future<String?> _getStudentId(String childName) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('name with initial',
            isEqualTo:
                childName) // Assuming 'name' field contains the student's name
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Return the student's UID
    }
    return null;
  }

  // Fetch the student's marks using their UID
  Future<List<Map<String, dynamic>>> _fetchMarks(String studentId) async {
    QuerySnapshot snapshot = await _firestore
        .collection(
            'examMarks') // Assuming you have a 'marks' collection for storing exam results
        .where('studentId', isEqualTo: studentId)
        .get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's UID (which is the parent's UID)
    String parentId =
        _auth.currentUser!.uid; // Get the current logged-in user's UID

    return FutureBuilder<String?>(
      future: _getChildName(
          parentId), // Get the child's name from the parent's data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        String? childName = snapshot.data;

        if (childName == null) {
          return const Center(child: Text('No child data found.'));
        }

        // Fetch the student's UID based on the child's name
        return FutureBuilder<String?>(
          future: _getStudentId(
              childName), // Get the student's UID using the child's name
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            String? studentId = snapshot.data;

            if (studentId == null) {
              return const Center(child: Text('Student not found.'));
            }

            // Fetch the student's marks
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMarks(
                  studentId), // Get the student's marks based on their UID
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No marks available.'));
                }

                List<Map<String, dynamic>> marks = snapshot.data!;

                return ListView.builder(
                  itemCount: marks.length,
                  itemBuilder: (context, index) {
                    final mark = marks[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                              'Subject: ${mark['teacherSubject']}'), // Display the subject
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Exam Type: ${mark['examType']}'), // Display the exam type (e.g., term1)
                              Text(
                                  'Stream: ${mark['stream']}'), // Display the stream (e.g., Physical Science)
                              Text(
                                  'Teacher: ${mark['teacherName']}'), // Display the teacher's name
                              Text(
                                  'Marks: ${mark['marks'][mark['teacherSubject']]}'), // Display the marks for the subject
                            ],
                          ),
                          trailing: Text(
                            'Date: ${mark['examDate']}',
                            //'Date: ${DateTime.parse(mark['date']).day}/${DateTime.parse(mark['date']).month}/${DateTime.parse(mark['date']).year}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )

                        /*child: ListTile(
                        title: Text('Subject: ${mark['teacherSubject']}'),
                        subtitle: Text('Marks: ${mark['examType']}'),
                        trailing: Text(
                        'Date: ${DateTime.parse(mark['date']).day}/${DateTime.parse(mark['date']).month}/${DateTime.parse(mark['date']).year}',
                        style: const TextStyle(color: Colors.grey),
                         ),
                      ),*/
                        );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}*/
