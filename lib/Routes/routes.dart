import 'package:flutter/material.dart';
import 'package:s20/Screens/MarkedAttendance.dart';
import 'package:s20/Screens/Register.dart';
import 'package:s20/Screens/SplashScreen.dart';
import 'package:s20/Screens/TAttendance.dart';
import 'package:s20/Screens/login.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String takeAttendance = '/takeAttendance';
  static const String markedAttendance = '/markedAttendance';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    // home: (context) => const HomePage(),
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
    takeAttendance: (context) => AttendancePage(),
    markedAttendance: (context) => MarkedAttendanceListPage()
  };
}
