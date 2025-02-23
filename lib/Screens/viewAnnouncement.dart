import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      return teacherDoc['name with initial'];
    } else {
      return 'Unknown Teacher';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Redirect to login if no user is logged in
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Announcements'),
        backgroundColor: Colors.indigo,
        elevation: 0,
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final teacherId = announcement['teacherId'];

              return FutureBuilder<String>(
                future: _fetchTeacherName(teacherId),
                builder: (context, teacherSnapshot) {
                  if (teacherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  if (teacherSnapshot.hasError) {
                    return const SizedBox();
                  }

                  final teacherName = teacherSnapshot.data ?? 'Unknown Teacher';
                  final timestamp = (announcement['timestamp'] as Timestamp)
                      .toDate(); // Timestamp to DateTime
                  final formattedDate =
                      DateFormat('d MMM yyyy').format(timestamp);

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.indigo[300]),
                              const SizedBox(width: 8),
                              Text(
                                'Posted by: $teacherName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            announcement['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Target Audience: ${List<String>.from(announcement['targetAudience']).join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            announcement['content'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              _showDetailsDialog(context, announcement);
                            },
                            child: const Text(
                              'Read more',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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

  void _showDetailsDialog(
      BuildContext context, Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(announcement['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['content'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
