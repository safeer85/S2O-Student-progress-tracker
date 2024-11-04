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

      await FirebaseMessaging.instance.subscribeToTopic("announcements");

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Announcement posted!")));

      _titleController.clear();
      _contentController.clear();

      await flutterLocalNotificationsPlugin.show(
        0,
        "Announcement Sent",
        "Your announcement was posted successfully!",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'teacher_notification_channel',
            'Teacher Notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
      );
    } catch (e) {
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



/*import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    try {
      // Add the announcement to Firestore
      await _firestore.collection('announcements').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'teacherId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'targetAudience': targetAudience,
      });

      // Subscribe the device to the announcements topic for FCM notifications
      await FirebaseMessaging.instance.subscribeToTopic("announcements");

      // Show a snackbar as feedback
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Announcement posted!")));

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      // Show a local notification to the teacher confirming the announcement
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        "Announcement Sent",
        "Your announcement was posted successfully!",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'teacher_notification_channel', // Channel ID
            'Teacher Notifications', // Channel name
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
      );
    } catch (e) {
      print("Error posting announcement: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error posting announcement.")));
    }
  }

  /* Future<void> _postAnnouncement() async {
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

      await FirebaseMessaging.instance.subscribeToTopic("announcements");

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Announcement posted!")));
      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      print("Error posting announcement: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error posting announcement.")));
    }
  }*/

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
}*/


/*import 'package:firebase_messaging/firebase_messaging.dart';
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
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic("announcements");
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
*/