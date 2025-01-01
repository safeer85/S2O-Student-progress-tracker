import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Services/ExamMarksService.dart';

class StudentMarksPage extends StatefulWidget {
  @override
  _StudentMarksPageState createState() => _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  late Stream<Map<String, Map<String, List<ExamMarks>>>> _examMarksStream;
  late String studentId;
  final ExamMarksService _examMarksService = ExamMarksService();

  @override
  void initState() {
    super.initState();

    // Get the current logged-in user's ID from FirebaseAuth
    studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (studentId.isNotEmpty) {
      // Fetch exam marks grouped by subject, then exam type, and ranked for the student
      _examMarksStream = _examMarksService.getRankedMarks(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Marks'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text('You are not logged in.',
              style: TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Marks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<Map<String, Map<String, List<ExamMarks>>>>(
        stream: _examMarksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Something went wrong!',
                    style: TextStyle(color: Colors.red, fontSize: 16)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No marks found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final groupedMarks = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: groupedMarks.keys.map((subject) {
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      const Divider(),
                      ...groupedMarks[subject]!.keys.map((examType) {
                        final examMarksList = groupedMarks[subject]![examType]!;
                        return ExpansionTile(
                          title: Text(
                            'Exam Type: $examType',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: examMarksList.map((examMarks) {
                            var totalMarks = examMarks.marks?.values
                                    .map(int.parse)
                                    .reduce((a, b) => a + b) ??
                                0;
                            return Card(
                              margin: const EdgeInsets.all(8),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  'Exam Date: ${examMarks.examDate}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Stream: ${examMarks.stream ?? 'N/A'}'),
                                    Text(
                                        'Teacher: ${examMarks.teacherName ?? 'N/A'}'),
                                    const SizedBox(height: 10),
                                    const Text('Marks:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    ...(examMarks.marks?.entries.map((entry) {
                                          return Text(
                                              '${entry.key}: ${entry.value}');
                                        }) ??
                                        []),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}





/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Services/ExamMarksService.dart';

class StudentMarksPage extends StatefulWidget {
  @override
  _StudentMarksPageState createState() => _StudentMarksPageState();
}

class _StudentMarksPageState extends State<StudentMarksPage> {
  late Stream<Map<String, Map<String, List<ExamMarks>>>> _examMarksStream;
  late String studentId;
  final ExamMarksService _examMarksService = ExamMarksService();

  @override
  void initState() {
    super.initState();

    // Get the current logged-in user's ID from FirebaseAuth
    studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (studentId.isNotEmpty) {
      // Fetch exam marks grouped by subject, then exam type, and ranked for the student
      _examMarksStream = _examMarksService.getRankedMarks(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
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
      body: StreamBuilder<Map<String, Map<String, List<ExamMarks>>>>(
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

          final groupedMarks = snapshot.data!;

          return ListView(
            children: groupedMarks.keys.map((subject) {
              // For each subject, we need to display the exam types and ranked marks
              return ExpansionTile(
                title: Text(subject),
                children: groupedMarks[subject]!.keys.map((examType) {
                  final examMarksList = groupedMarks[subject]![examType]!;
                  return ExpansionTile(
                    title: Text('Exam Type: $examType'),
                    children: examMarksList.map((examMarks) {
                      var totalMarks = examMarks.marks?.values
                              .map(int.parse)
                              .reduce((a, b) => a + b) ??
                          0;
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Exam Date: ${examMarks.examDate}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stream: ${examMarks.stream ?? 'N/A'}'),
                              Text(
                                  'Teacher: ${examMarks.teacherName ?? 'N/A'}'),
                              Text('Marks:'),
                              ...(examMarks.marks?.entries.map((entry) {
                                    return Text('${entry.key}: ${entry.value}');
                                  }) ??
                                  []),
                              Text('Total Marks: $totalMarks'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}*/


