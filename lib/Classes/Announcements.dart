import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String? id; // Firestore document ID
  String? content; // Announcement content
  List<String>?
      targetAudience; // Array of audience (e.g., "students", "parents")
  String? teacherId; // ID of the teacher who made the announcement
  Timestamp? timestamp; // Time the announcement was created
  String? title; // Title of the announcement

  // Constructor
  Announcement({
    this.id,
    this.content,
    this.targetAudience,
    this.teacherId,
    this.timestamp,
    this.title,
  });

  // Factory constructor to create an Announcement object from Firestore data
  factory Announcement.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Announcement(
      id: documentId,
      content: data['content'] as String?,
      targetAudience: data['targetAudience'] != null
          ? List<String>.from(data['targetAudience'])
          : null,
      teacherId: data['teacherId'] as String?,
      timestamp: data['timestamp'] as Timestamp?,
      title: data['title'] as String?,
    );
  }

  // Method to convert an Announcement object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'targetAudience': targetAudience,
      'teacherId': teacherId,
      'timestamp': timestamp,
      'title': title,
    };
  }
}
