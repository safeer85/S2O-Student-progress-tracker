import 'package:flutter/material.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentMarksPage extends StatefulWidget {
  @override
  _StudentMarksPageState createState() => _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  late Stream<List<ExamMarks>> _examMarksStream;
  String? studentId;

  @override
  void initState() {
    super.initState();

    // Get the current logged-in user's ID from FirebaseAuth
    studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId != null) {
      // Set up the stream to fetch the student's exam marks
      _examMarksStream = FirebaseFirestore.instance
          .collection('examMarks')
          .where('studentId', isEqualTo: studentId)
          .orderBy('examDate',
              descending: false) // Order by exam date ascending
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => ExamMarks.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Student Marks'),
        ),
        body: Center(child: Text('You are not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Marks'),
      ),
      body: StreamBuilder<List<ExamMarks>>(
        stream: _examMarksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No marks found.'));
          }

          final examMarksList = snapshot.data!;

          return ListView.builder(
            itemCount: examMarksList.length,
            itemBuilder: (context, index) {
              final examMarks = examMarksList[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Exam Date: ${examMarks.examDate}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam Type: ${examMarks.examType ?? 'N/A'}'),
                      Text('Stream: ${examMarks.stream ?? 'N/A'}'),
                      Text('Teacher: ${examMarks.teacherName ?? 'N/A'}'),
                      Text('Subject: ${examMarks.teacherSubject ?? 'N/A'}'),
                      Text('Marks:'),
                      ...(examMarks.marks?.entries.map((entry) {
                            return Text('${entry.key}: ${entry.value}');
                          }) ??
                          [])
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
