import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAnnouncementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch announcements from Firestore
  Future<List<Map<String, dynamic>>> _fetchAnnouncements() async {
    QuerySnapshot snapshot = await _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  // Fetch the teacher's name using teacherId (which is actually uid in users collection)
  Future<String> _fetchTeacherName(String teacherId) async {
    DocumentSnapshot teacherDoc =
        await _firestore.collection('users').doc(teacherId).get();
    if (teacherDoc.exists) {
      return teacherDoc[
          'name with initial']; // Assuming 'name' is a field in the 'users' collection
    } else {
      return 'Unknown Teacher'; // Return a default name if teacher is not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Announcements'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements available.'));
          }

          List<Map<String, dynamic>> announcements = snapshot.data!;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final teacherId = announcement[
                  'teacherId']; // Get teacherId (uid) from the announcement document

              return FutureBuilder<String>(
                future: _fetchTeacherName(
                    teacherId), // Fetch teacher name using teacherId (uid)
                builder: (context, teacherSnapshot) {
                  if (teacherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (teacherSnapshot.hasError) {
                    return ListTile(
                      title: Text(announcement['title']),
                      subtitle: Text('Error fetching teacher name'),
                    );
                  }

                  final teacherName = teacherSnapshot.data ?? 'Unknown Teacher';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      title: Text(announcement['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Posted by Teacher: $teacherName'),
                          const SizedBox(height: 5),
                          Text(
                              'Target Audience: ${List<String>.from(announcement['targetAudience']).join(', ')}'),
                          const SizedBox(height: 10),
                          Text(announcement['content']),
                        ],
                      ),
                      trailing: Text(
                        '${(announcement['timestamp'] as Timestamp).toDate().day}/${(announcement['timestamp'] as Timestamp).toDate().month}/${(announcement['timestamp'] as Timestamp).toDate().year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
