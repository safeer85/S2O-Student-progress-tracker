/*import 'package:flutter/material.dart';
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
}*/
import 'package:flutter/material.dart';
import 'package:s20/Routes/routes.dart';
import 'package:s20/components/Drawer.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Function to handle navigation based on selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define pages for Attendance and Announcement
    List<Widget> _pages = [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Attendance",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (widget.role == 'Teacher') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/takeAttendance');
                },
                icon: const Icon(Icons.check_circle),
                label: const Text("Take Attendance"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.markedAttendance);
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('See Recorded Attendance'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
            if (widget.role == 'Student') ...[
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to view attendance page
                },
                icon: const Icon(Icons.visibility),
                label: const Text("View Attendance"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Announcement",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (widget.role == 'Teacher') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.announcement);
                },
                icon: const Icon(Icons.announcement),
                label: const Text('Post Announcement'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.announcementlist);
                },
                icon: const Icon(Icons.list),
                label: const Text('View Announcements List'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const CustomDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, color: Colors.blueAccent),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement, color: Colors.blueAccent),
            label: 'Announcement',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
