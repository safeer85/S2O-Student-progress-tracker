import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Classes/Marks.dart'; // Assuming the ExamMarks class is in this file

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  StudentDetailPage({required this.student});

  // Fetch the student's exam marks from Firestore
  Stream<List<ExamMarks>> _getStudentExamMarks(String studentId) {
    return FirebaseFirestore.instance
        .collection('examMarks')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExamMarks.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  student['name with initial'][0],
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${student['firstName']} ${student['lastName']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Name with Initial: ${student['name with initial']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${student['email']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Stream: ${student['stream'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Batch: ${student['batch'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Exam Marks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ExamMarks>>(
                stream: _getStudentExamMarks(student['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error fetching exam marks',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No exam marks found for this student',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final examMarksList = snapshot.data!;
                  return ListView.builder(
                    itemCount: examMarksList.length,
                    itemBuilder: (context, index) {
                      final exam = examMarksList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${exam.examType} - ${exam.examDate}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var entry in (exam.marks ?? {}).entries)
                                Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}