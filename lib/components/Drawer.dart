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
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userDetails['userName']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            userDetails['userEmail']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userDetails['userRole']!,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: 24,
          color: Colors.blueAccent,
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
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