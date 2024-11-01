import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:s20/Routes/routes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showLocalNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  /*FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    sound: true,
  );*/
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'app_icon'); // Replace 'app_icon' with your icon name

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

void _showLocalNotification(RemoteMessage message) async {
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
