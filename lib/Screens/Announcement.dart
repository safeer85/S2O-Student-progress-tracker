import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isTeacher = false;
  List<String> targetAudience = ["students", "parents"]; // Default selection

  @override
  void initState() {
    super.initState();
    _checkIfTeacher();
  }

  // Check if the current user is a teacher
  Future<void> _checkIfTeacher() async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(uid).get();
      setState(() {
        isTeacher = userSnapshot.exists &&
            (userSnapshot.data() as Map<String, dynamic>)['role'] == 'Teacher';
      });
    }
  }

  // Post announcement to Firestore
  Future<void> _postAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    try {
      await _firestore.collection('announcements').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'teacherId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'targetAudience': targetAudience,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Announcement posted!")));
      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      print("Error posting announcement: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error posting announcement.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isTeacher) {
      return Scaffold(
        appBar: AppBar(title: Text("Create Announcement")),
        body: Center(child: Text("Access restricted to teachers only.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Create Announcement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Announcement Title"),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Announcement Content"),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            Text("Select Target Audience"),
            CheckboxListTile(
              title: Text("Students"),
              value: targetAudience.contains("students"),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    targetAudience.add("students");
                  } else {
                    targetAudience.remove("students");
                  }
                });
              },
            ),
            CheckboxListTile(
              title: Text("Parents"),
              value: targetAudience.contains("parents"),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    targetAudience.add("parents");
                  } else {
                    targetAudience.remove("parents");
                  }
                });
              },
            ),
            ElevatedButton(
              onPressed: _postAnnouncement,
              child: Text("Post Announcement"),
            ),
          ],
        ),
      ),
    );
  }
}
