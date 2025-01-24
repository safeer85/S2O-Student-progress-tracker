import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Screens/AddTeacherPage.dart';
import 'package:s20/Screens/ManageAdmin.dart';
import 'package:s20/Screens/OnlineUsePage.dart';
import 'package:s20/Screens/ParentManagePage.dart';
import 'package:s20/Screens/Register.dart';
import 'package:s20/Screens/StudentManage.dart';
import 'package:s20/components/Drawer.dart';
import 'package:s20/components/linkeditpage.dart';
import 'TeacherListPage.dart';

class AdminDashboard extends StatefulWidget {
  final Customuser user;

  const AdminDashboard({required this.user});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalUsers = 0;
  int teachersCount = 0;
  int studentsCount = 0;
  int parentsCount = 0;

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCounts();
  }

  Future<void> _fetchUserCounts() async {
    teachersCount = await _countUsersByRole('Teacher');
    studentsCount = await _countUsersByRole('Student');
    parentsCount = await _countUsersByRole('Parent');
    totalUsers = teachersCount + studentsCount + parentsCount;

    setState(() {});
  }

  Future<int> _countUsersByRole(String role) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black87 : Colors.orange.shade300,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) {
              if (value == 'Profile') {
                // Navigate to profile
              } else if (value == 'Logout') {
                // Handle logout
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Profile', child: Text('Profile')),
              PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: const StylishDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black87, Colors.black54]
                : [Colors.orange.shade300, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildFeaturesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.orange, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Good ${_getGreeting()}, ${widget.user.nameWithInitial}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FadeInLeft(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Total Users', totalUsers, Icons.people, Colors.blue),
            _buildStatCard('Teachers', teachersCount, Icons.person, Colors.orange),
            _buildStatCard('Students', studentsCount, Icons.school, Colors.green),
            _buildStatCard('Parents', parentsCount, Icons.family_restroom, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: BounceInUp(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildFeaturesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildFeatureCard(
          icon: Icons.app_registration,
          title: 'User Registration',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.school,
          title: 'Manage Students',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentManagePage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.family_restroom,
          title: 'Manage Parents',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ParentManagePage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.person,
          title: 'Manage Teachers',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTeacherPage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.chat,
          title: 'Chat with Teachers',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherListPage(
                getTeachersStream: _getTeachers,
                currentUser: widget.user,
                generateChatId: _generateChatId,
              ),
            ),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.admin_panel_settings,
          title: 'Manage Admins',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageAdminsPage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.link,
          title: 'Edit Video Links',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminUpdateYoutubeLinkPage()),
          ),
        ),
        _buildFeatureCard(
          icon: Icons.link,
          title: 'Online Users',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OnlineUsersPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return SlideInUp(
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<Customuser>> _getTeachers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Customuser.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  String _generateChatId(String? userId1, String? userId2) {
    final sortedIds = [userId1!, userId2!]..sort();
    return sortedIds.join('_');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 18) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}