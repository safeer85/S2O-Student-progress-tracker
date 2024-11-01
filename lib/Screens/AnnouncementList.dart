import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementsListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String? teacherId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Sent Announcements")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('announcements')
            .where('teacherId',
                isEqualTo: teacherId) // Filter by logged-in teacher
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No announcements found."));
          }

          final announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return ListTile(
                title: Text(announcement['title']),
                subtitle: Text(announcement['content']),
                trailing: Text(
                  announcement['timestamp'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                              announcement['timestamp'].millisecondsSinceEpoch)
                          .toString()
                      : 'No Date',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
