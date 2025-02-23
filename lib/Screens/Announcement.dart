import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  List<String> targetAudience = ["students", "parents"];

  @override
  void initState() {
    super.initState();
    _checkIfTeacher();
    _initializeLocalNotifications();
    _listenForFCM();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _listenForFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'announcements_channel',
      'Announcements',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
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

  Future<void> _postAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      // Add announcement to Firestore
      await _firestore.collection('announcements').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'teacherId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'targetAudience': targetAudience,
      });

      // Send notification using FCM
      for (String audience in targetAudience) {
        await sendNotificationToTopic(audience);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Announcement posted!")),
      );

      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error posting announcement.")),
      );
    }
  }

  Future<void> sendNotificationToTopic(String topic) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final serverKey = '117615282849711579033'; // Replace with your Firebase server key

    final message = {
      "to": "/topics/$topic",
      "notification": {
        "title": _titleController.text,
        "body": _contentController.text,
        "sound": "default",
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(message),
      );
    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }

  Future<void> subscribeToTopics() async {
    if (isTeacher) {
      return; // Teachers don't need to subscribe to student/parent topics
    }

    if (targetAudience.contains('students')) {
      await FirebaseMessaging.instance.subscribeToTopic('students');
    }

    if (targetAudience.contains('parents')) {
      await FirebaseMessaging.instance.subscribeToTopic('parents');
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
    if (!isTeacher) {
      return Scaffold(
        appBar: AppBar(title: Text("Create Announcement")),
        body: Center(child: Text("Loading...")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Announcement"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Announcement Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: "Announcement Content",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Text(
              "Select Target Audience",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              child: Column(
                children: [
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
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _postAnnouncement,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color.fromARGB(255, 122, 167, 244),
              ),
              child: Text(
                "Post Announcement",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
