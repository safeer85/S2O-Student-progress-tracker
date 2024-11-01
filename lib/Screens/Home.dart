import 'package:flutter/material.dart';
import 'package:s20/Routes/routes.dart';

class HomePage extends StatelessWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to the Home Page!"),
            if (role == 'Student') ...[
              ElevatedButton(
                onPressed: () {
                  // Navigate to view attendance page
                },
                child: const Text("View Attendance"),
              ),
            ],
            if (role == 'Teacher') ...[
              ElevatedButton(
                onPressed: () {
                  // Navigate to take attendance page
                  Navigator.pushNamed(context, '/takeAttendance');
                },
                child: const Text("Take Attendance"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to take attendance page
                  Navigator.pushNamed(context, AppRoutes.markedAttendance);
                },
                child: const Text('See Recorded Attendance'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to take attendance page
                  Navigator.pushNamed(context, AppRoutes.announcement);
                },
                child: const Text('announcement'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to take attendance page
                  Navigator.pushNamed(context, AppRoutes.announcementlist);
                },
                child: const Text('announcementlist'),
              ),
            ],
            if (role == 'Parent') ...[
              ElevatedButton(
                onPressed: () {
                  // Navigate to view child's progress
                },
                child: const Text("View Child's Progress"),
              ),
            ],
            if (role == 'Principal') ...[
              ElevatedButton(
                onPressed: () {
                  // Navigate to the principal's dashboard
                },
                child: const Text("Principal Dashboard"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
