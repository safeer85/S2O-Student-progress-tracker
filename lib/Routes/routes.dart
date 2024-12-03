import 'package:flutter/material.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Screens/Announcement.dart';
import 'package:s20/Screens/AnnouncementList.dart';
//import 'package:s20/Screens/Exam.dart';
import 'package:s20/Screens/MarkedAttendance.dart';
import 'package:s20/Screens/ParentMarks.dart';
import 'package:s20/Screens/Registerold.dart';
import 'package:s20/Screens/SplashScreen.dart';
import 'package:s20/Screens/TAttendance.dart';
import 'package:s20/Screens/login.dart';
import 'package:s20/Screens/parentAttendance.dart';
import 'package:s20/Screens/setting.dart';
import 'package:s20/Screens/viewAnnouncement.dart';
import 'package:s20/Screens/viewAttendance.dart';
import 'package:s20/Screens/viewMarks.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String takeAttendance = '/takeAttendance';
  static const String markedAttendance = '/markedAttendance';
  static const String announcement = '/announcement';
  static const String announcementlist = '/announcementlist';
  static const String examMarks = '/examMarks';
  static const String viewAttendance = '/viewAttendance';
  static const String viewAnnouncement = '/viewAnnouncement';
  static const String viewchildmarks = '/viewchildmarks';
  static const String viewChildAttendance = '/viewChildAttendance';
  static const String viewChildMarks = '/viewChildMarks';
  static const String viewMarks = '/viewMarks';
  static const String setting = '/setting';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    // home: (context) => const HomePage(),
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
    takeAttendance: (context) => AttendancePage(),
    markedAttendance: (context) => MarkedAttendanceListPage(),
    announcement: (context) => CreateAnnouncementPage(),
    announcementlist: (context) => AnnouncementsListPage(),
    viewAttendance: (context) => ViewAttendancePage(),
    viewAnnouncement: (context) => ViewAnnouncementPage(),
    setting: (context) => SettingsPage(),
    //viewchildmarks: (context) => ViewMarksPage(),
    viewChildAttendance:
        (context) //=> AttendanceDetailPage(childName: childName)
        {
      final String childName =
          ModalRoute.of(context)!.settings.arguments as String;
      return AttendanceDetailPage(
          childName: childName); // Pass childName to AttendanceDetailPage
    },
    viewChildMarks: (context) //=> AttendanceDetailPage(childName: childName)
        {
      final String childName =
          ModalRoute.of(context)!.settings.arguments as String;
      return ViewChildMarksPage(
          childName: childName); // Pass childName to AttendanceDetailPage
    },
    viewMarks: (context) => StudentMarksPage(),
    examMarks: (context) {
      final String childName =
          ModalRoute.of(context)!.settings.arguments as String;
      return ViewChildMarksPage(
          childName: childName); // Pass childName to AttendanceDetailPage
    }
    // examMarks: (context) => ExamMarksEntryPage(teacherName: 'YourTeacherName')
  };
}
