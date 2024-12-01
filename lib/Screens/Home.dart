import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s20/Routes/routes.dart';
import 'package:s20/components/Drawer.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({Key? key, required this.role}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildResponsivePageContent(
        title: "Attendance",
        subtitle: "Manage attendance efficiently",
        roleSpecificActions: widget.role == 'Teacher'
            ? [
          _buildFeatureCard(
            title: "Take Attendance",
            description: "Record attendance for your class",
            icon: Icons.check_circle,
            onPressed: () {
              Navigator.pushNamed(context, '/takeAttendance');
            },
          ),
          _buildFeatureCard(
            title: "See Recorded Attendance",
            description: "View attendance records",
            icon: Icons.list_alt,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.markedAttendance);
            },
          ),
        ]
            : [
          _buildFeatureCard(
            title: "View Attendance",
            description: "See your attendance records",
            icon: Icons.visibility,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.viewAttendance);
            },
          ),
        ],
      ),
      _buildResponsivePageContent(
        title: "Announcements",
        subtitle: "Stay updated with the latest news",
        roleSpecificActions: widget.role == 'Teacher'
            ? [
          _buildFeatureCard(
            title: "Post Announcement",
            description: "Share important updates",
            icon: Icons.announcement,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.announcement);
            },
          ),
          _buildFeatureCard(
            title: "View Announcements",
            description: "Browse past announcements",
            icon: Icons.list,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.announcementlist);
            },
          ),
        ]
            : [
          _buildFeatureCard(
            title: "View Announcements",
            description: "Check updates and notices",
            icon: Icons.announcement,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.viewAnnouncement);
            },
          ),
        ],
      ),
      _buildResponsivePageContent(
        title: "Exams",
        subtitle: "Manage and track exam performance",
        roleSpecificActions: widget.role == 'Teacher'
            ? [
          _buildFeatureCard(
            title: "Enter Exam Marks",
            description: "Record student marks",
            icon: Icons.task,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.examMarks);
            },
          ),
        ]
            : widget.role == 'Parent'
            ? [
          _buildFeatureCard(
            title: "View Marks",
            description: "Check your child's performance",
            icon: Icons.task,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.viewchildmarks);
            },
          ),
        ]
            : [],
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
        backgroundColor: Colors.transparent,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_rounded),
            label: 'Exams',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Color(0xFF5B86E5),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildResponsivePageContent({
    required String title,
    required String subtitle,
    required List<Widget> roleSpecificActions,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeInDown(
            delay: Duration(milliseconds: 200),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: roleSpecificActions.length,
            itemBuilder: (context, index) {
              return roleSpecificActions[index];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return BounceInUp(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF36D1DC),
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B86E5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}