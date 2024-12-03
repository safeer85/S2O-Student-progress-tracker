import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String? id;
  String? user1;
  String? user2;
  final Timestamp timestamp;
  Chat({this.id, this.user1, this.user2, required this.timestamp});

  // Convert Firestore data to Chat object
  factory Chat.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Chat(
      id: documentId,
      user1: data['user1'],
      user2: data['user2'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1': user1,
      'user2': user2,
      'timestamp': timestamp,
    };
  }
}
// Convert a Chat object to Firestore-compatible map
  