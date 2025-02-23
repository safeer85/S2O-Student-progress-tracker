import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s20/Screens/setting.dart';

class StylishDrawer extends StatefulWidget {
  const StylishDrawer({Key? key}) : super(key: key);

  @override
  _StylishDrawerState createState() => _StylishDrawerState();
}

class _StylishDrawerState extends State<StylishDrawer> {
  late Future<Map<String, String>> _userDetailsFuture;
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _userDetailsFuture = fetchUserDetails();
  }

  Future<Map<String, String>> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in');
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }

    final data = userDoc.data()!;
    final userName = data['name with initial'] as String? ?? 'Unknown User';
    final userEmail = data['email'] as String? ?? 'No Email';
    final userRole = data['role'] as String? ?? 'Unknown Role';

    return {'userName': userName, 'userRole': userRole, 'userEmail': userEmail};
  }
  Future<void> logoutUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isOnline': false});
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      log('Logout failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // If no user is logged in, return a placeholder or prompt to log in.
      return const Center(
        child: Text(
          'Please log in to access the menu.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return FutureBuilder<Map<String, String>>(
      future: _userDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user details'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final userDetails = snapshot.data!;

        return Drawer(
          child: Column(
            children: [
              _buildHeader(userDetails), // Stylish Header
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDrawerItem(
                      iconPath: 'assets/icons/feedback.svg',
                      text: 'Feedback',
                      onTap: () {
                        // Navigate to Feedback Page
                      },
                    ),
                    _buildDrawerItem(
                      iconPath: 'assets/icons/settings.svg',
                      text: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      iconPath: 'assets/icons/help.svg',
                      text: 'Help',
                      onTap: () {
                        // Navigate to Help Page
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Version 2.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header with Profile Information
  Widget _buildHeader(Map<String, String> userDetails) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: userDetails['profileImage'] != null
                    ? ClipOval(
                  child: Image.network(
                    userDetails['profileImage']!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Icon(
                  Icons.circle,
                  size: 18,
                  color: Colors.greenAccent,
                ), // Optionally indicate active status.
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userDetails['userName']!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userDetails['userEmail']!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              userDetails['userRole']!,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Items
  Widget _buildDrawerItem({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Card(
      elevation: isSelected ? 6 : 4, // Slightly higher elevation for the selected item
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Larger radius for smoother edges
      ),
      color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.blueAccent.withOpacity(0.2),
        highlightColor: Colors.blueAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 28,
                color: isSelected ? Colors.blueAccent : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blueAccent : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Logout Confirmation
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    logoutUser(user!.uid);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}