import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? content;
  Timestamp? timestamp;

  Message({this.senderId, this.content, this.timestamp});

  // Convert Firestore data to Message object
  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      content: data['content'],
      timestamp: data['timestamp'],
    );
  }

  // Convert Message object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
