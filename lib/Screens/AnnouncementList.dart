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
      appBar: AppBar(
        title: Text("Sent Announcements"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('announcements')
            .where('teacherId', isEqualTo: teacherId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No announcements found.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final title = announcement['title'];
              final content = announcement['content'];
              final timestamp = announcement['timestamp'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      announcement['timestamp'].millisecondsSinceEpoch)
                  : null;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 18, 20, 23),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          timestamp != null
                              ? "${timestamp.toLocal()}".split(' ')[0]
                              : 'No Date',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    children: [
                      Divider(color: Colors.grey[300]),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
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


/*import 'package:flutter/material.dart';
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
}*/
