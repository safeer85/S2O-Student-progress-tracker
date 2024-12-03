import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementsListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to delete an announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).delete();
    } catch (e) {
      print("Error deleting announcement: $e");
    }
  }

  // Method to navigate to the Edit page (you'll need to create EditAnnouncementPage)
  void navigateToEditPage(BuildContext context, String announcementId,
      String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnnouncementPage(
            announcementId: announcementId, title: title, content: content),
      ),
    );
  }

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
              final announcementId = announcement.id;
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => navigateToEditPage(
                            context,
                            announcementId,
                            title,
                            content,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteAnnouncement(announcementId),
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

class EditAnnouncementPage extends StatefulWidget {
  final String announcementId;
  final String title;
  final String content;

  EditAnnouncementPage({
    required this.announcementId,
    required this.title,
    required this.content,
  });

  @override
  _EditAnnouncementPageState createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _contentController.text = widget.content;
  }

  // Method to save the edited announcement
  Future<void> saveEditedAnnouncement() async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementId)
          .update({
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp':
            FieldValue.serverTimestamp(), // Update timestamp to current time
      });
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print("Error updating announcement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Announcement"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEditedAnnouncement,
              child: Text('Save Changes'),
            ),
          ],
        ),
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
}*/


