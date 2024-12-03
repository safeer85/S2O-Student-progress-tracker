import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Classes/User.dart'; // Make sure this import is correct
import 'package:s20/Routes/routes.dart';
import 'package:s20/Screens/UserListpage.dart';
import 'package:s20/components/Drawer.dart';
import 'package:s20/Screens/Exam.dart';
import 'package:s20/Screens/teacherViewMarks.dart';

class HomePage extends StatefulWidget {
  final Customuser user;
  // final ExamMarks marks; // Pass Customuser object

  const HomePage({Key? key, required this.user}) : super(key: key);

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
        roleSpecificActions: widget.user.role == 'Teacher'
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
            : widget.user.role == 'Parent'
                ? [
                    _buildFeatureCard(
                      title: "View Child's Attendance",
                      description: "See your child's attendance records",
                      icon: Icons.visibility,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes
                              .viewChildAttendance, // Navigate to child's attendance page
                          arguments:
                              widget.user.childName, // Pass the child's name
                        );
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
        roleSpecificActions: widget.user.role == 'Teacher'
            ? [
                _buildFeatureCard(
                  title: "Post Announcement",
                  description: "Share important updates",
                  icon: Icons.notification_important,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.announcement);
                  },
                ),
              ]
            : [
                _buildFeatureCard(
                  title: "View Announcements",
                  description: "Read the latest updates",
                  icon: Icons.notifications,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.viewAnnouncement);
                  },
                ),
              ],
      ),
      _buildResponsivePageContent(
        title: "Exams",
        subtitle: "Manage exams and results",
        roleSpecificActions: widget.user.role == 'Teacher'
            ? [
                _buildFeatureCard(
                  title: "Enter Marks",
                  description: "Input term exam marks",
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterMarksPage(user: widget.user),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  title: "View Student Marks",
                  description: "you can see the students marks",
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewMarksPage(user: widget.user),
                      ),
                    );
                  },
                ),
              ]
            : widget.user.role == 'Parent'
                ? [
                    _buildFeatureCard(
                      title: "View Child's Marks",
                      description: "See your child's Marks here",
                      icon: Icons.visibility,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes
                              .viewChildMarks, // Navigate to child's attendance page
                          arguments:
                              widget.user.childName, // Pass the child's name
                        );
                      },
                    ),
                  ]
                : widget.user.role == 'Student'
                    ? [
                        _buildFeatureCard(
                          title: "View Your Marks",
                          description: "See your child's Marks here",
                          icon: Icons.visibility,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .viewMarks, // Navigate to child's attendance page
                              // Pass the child's name
                            );
                          },
                        ),
                      ]
                    : [],
      ),
      _buildResponsivePageContent(
        title: "chat",
        subtitle: "Manage exams and results",
        roleSpecificActions: widget.user.role == 'Teacher'
            ? [
                _buildFeatureCard(
                  title: "Chat",
                  description: "chat with others",
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListPage(user: widget.user),
                      ),
                    );
                  },
                ),
              ]
            : widget.user.role == 'Parent'
                ? [
                    _buildFeatureCard(
                      title: "chat",
                      description: "chat with others",
                      icon: Icons.chat,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserListPage(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ]
                : widget.user.role == 'Student'
                    ? [
                        _buildFeatureCard(
                          title: "chat",
                          description: "chat with others",
                          icon: Icons.visibility,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserListPage(user: widget.user),
                              ),
                            );
                          },
                        ),
                      ]
                    : [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello ${widget.user.nameWithInitial}"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Exams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildResponsivePageContent({
    required String title,
    required String subtitle,
    required List<Widget> roleSpecificActions,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ...roleSpecificActions,
              ],
            ),
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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(description),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
