import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s20/Classes/Marks.dart';

class ExamMarksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch, group, and rank marks by subject and exam type
  Stream<Map<String, Map<String, List<ExamMarks>>>> getRankedMarks(
      String studentId) {
    return _firestore
        .collection('examMarks')
        .where('studentId', isEqualTo: studentId)
        .orderBy('examDate', descending: false)
        .snapshots()
        .map((querySnapshot) {
      // Grouping exam marks by subject and exam type
      Map<String, Map<String, List<ExamMarks>>> groupedMarks = {};

      for (var doc in querySnapshot.docs) {
        var examMarks = ExamMarks.fromFirestore(doc.data(), doc.id);

        // Group marks by subject and exam type
        if (examMarks.teacherSubject != null && examMarks.examType != null) {
          if (!groupedMarks.containsKey(examMarks.teacherSubject!)) {
            groupedMarks[examMarks.teacherSubject!] = {};
          }

          if (!groupedMarks[examMarks.teacherSubject!]!
              .containsKey(examMarks.examType!)) {
            groupedMarks[examMarks.teacherSubject!]![examMarks.examType!] = [];
          }

          groupedMarks[examMarks.teacherSubject!]![examMarks.examType!]!
              .add(examMarks);
        }
      }

      // Now rank the marks for each exam type within each subject
      groupedMarks.forEach((subject, examTypes) {
        examTypes.forEach((examType, marksList) {
          marksList.sort((a, b) {
            // Rank by marks (assuming we have a field like 'marks' which contains the student's marks)
            var aMarks =
                a.marks?.values.map(int.parse).reduce((a, b) => a + b) ?? 0;
            var bMarks =
                b.marks?.values.map(int.parse).reduce((a, b) => a + b) ?? 0;
            return bMarks.compareTo(aMarks); // Descending order
          });
        });
      });

      return groupedMarks;
    });
  }
}
