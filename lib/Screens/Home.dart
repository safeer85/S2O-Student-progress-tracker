import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:s20/Classes/User.dart'; // Make sure this import is correct
import 'package:s20/Routes/routes.dart';
import 'package:s20/Screens/StudentViewDownload.dart';
import 'package:s20/Screens/TeacherResource.dart';
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
        role: widget.user.role,
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
                _buildFeatureCard(
                  title: "View posted Announcement List",
                  description: "manage posted announcments",
                  icon: Icons.notification_important,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.announcementlist);
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
        role: widget.user.role,
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
        role: widget.user.role,
      ),
      _buildResponsivePageContent(
        title: "Resources",
        subtitle: "Access and share learning materials",
        roleSpecificActions: widget.user.role == 'Teacher'
            ? [
                _buildFeatureCard(
                  title: "Share Resources",
                  description: "Upload and share resources with students",
                  icon: Icons.upload_file,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeacherResourceSharePage(user: widget.user),
                      ),
                    );
                  },
                ),
              ]
            : widget.user.role == 'Student'
                ? [
                    _buildFeatureCard(
                      title: "View Resources",
                      description: "Access resources shared by your teacher",
                      icon: Icons.folder_open,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentViewDownloadPage(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ]
                : [],
        role: widget.user.role,
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
        role: widget.user.role,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello ${widget.user.nameWithInitial}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1A237E)
              ], // Dark blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8, // Add a subtle shadow for depth
      ),
      drawer: const StylishDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
            icon: Icon(Icons.school),
            label: 'Exams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        backgroundColor: Colors.white, // Set background color
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        showUnselectedLabels: true, // Display labels for unselected items
        type: BottomNavigationBarType.fixed, // Prevent shifting effect
      ),
    );
  }


  Widget _buildResponsivePageContent({
    required String title,
    required String subtitle,
    required List<Widget> roleSpecificActions,
    required String? role,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ...roleSpecificActions,
                const SizedBox(height: 20),
                if (role == "Student") ...[
                  const Text(
                    "🌟 \"Education is the passport to the future, for tomorrow belongs to those who prepare for it today.\" – Malcolm X",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "💡 \"The beautiful thing about learning is that no one can take it away from you.\" – B.B. King",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('youtube_links')
                          .doc('link')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 200,
                              color: Colors.white,
                            ),
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text(
                            'YouTube video is not available.',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          );
                        }
                        final youtubeUrl = snapshot.data!.get('url') as String?;
                        final videoId =
                        YoutubePlayer.convertUrlToId(youtubeUrl ?? '');
                        if (videoId == null) {
                          return const Text(
                            'Invalid YouTube link in the database.',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          );
                        }
                        final YoutubePlayerController _controller =
                        YoutubePlayerController(
                          initialVideoId: videoId,
                          flags: const YoutubePlayerFlags(
                            autoPlay: false,
                            mute: false,
                          ),
                        );
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: YoutubePlayer(
                            controller: _controller,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.blueAccent,
                            onReady: () {
                              debugPrint("YouTube player is ready.");
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        splashColor: Colors.blueAccent.withOpacity(0.2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1E88E5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}