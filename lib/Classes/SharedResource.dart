import 'package:cloud_firestore/cloud_firestore.dart';

class SharedResource {
  final String id;
  final String teacherId;
  final String title;
  final String description;
  final String fileType;
  final String fileUrl;
  final String? batch;
  final String? stream;
  final DateTime timestamp;

  SharedResource({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.fileType,
    required this.fileUrl,
    this.batch,
    this.stream,
    required this.timestamp,
  });

  factory SharedResource.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return SharedResource(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fileType: data['fileType'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      batch: data['batch'],
      stream: data['stream'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'batch': batch,
      'stream': stream,
      'timestamp': timestamp,
    };
  }
}
