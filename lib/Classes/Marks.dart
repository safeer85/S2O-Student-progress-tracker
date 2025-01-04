import 'package:cloud_firestore/cloud_firestore.dart';

class ExamMarks {
  String? id; // Firestore document ID
  String? examDate; // Date of the exam
  String? examType; // Type of the exam (e.g., unit1, term)
  Map<String, String>? marks; // Map of subject names to marks
  String? stream; // Student's stream (e.g., Physical Science)
  String? studentId; // ID of the student
  String? teacherName; // Name of the teacher
  String? teacherSubject; // Subject taught by the teacher
  Timestamp? timestamp;
  String? batch; // Time the exam record was created

  // Constructor
  ExamMarks({
    this.id,
    this.examDate,
    this.examType,
    this.marks,
    this.stream,
    this.studentId,
    this.teacherName,
    this.teacherSubject,
    this.timestamp,
    this.batch,
  });

  // Factory constructor to create an ExamMarks object from Firestore data
  factory ExamMarks.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return ExamMarks(
      id: documentId,
      examDate: data['examDate'] as String?,
      examType: data['examType'] as String?,
      marks: data['marks'] != null
          ? Map<String, String>.from(data['marks'])
          : null,
      stream: data['stream'] as String?,
      studentId: data['studentId'] as String?,
      teacherName: data['teacherName'] as String?,
      teacherSubject: data['teacherSubject'] as String?,
      timestamp: data['timestamp'] as Timestamp?,
      batch: data['batch'] as String?,
    );
  }

  // Method to convert an ExamMarks object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'examDate': examDate,
      'examType': examType,
      'marks': marks,
      'stream': stream,
      'studentId': studentId,
      'teacherName': teacherName,
      'teacherSubject': teacherSubject,
      'timestamp': timestamp,
      'batch': batch,
    };
  }
}
