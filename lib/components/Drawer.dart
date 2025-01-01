import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s20/Routes/routes.dart';
import 'package:s20/Screens/setting.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<Map<String, String>> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in');
    }

    // Fetch data from Firestore users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }

    final data = userDoc.data()!;
    final userName = data['name with initial'] as String? ?? 'Unknown User';
    final userRole = data['role'] as String? ?? 'Unknown Role';

    return {'userName': userName, 'userRole': userRole};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: fetchUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching user details'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No data available'),
          );
        }

        final userDetails = snapshot.data!;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blueAccent),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      // backgroundImage: AssetImage('path/to/profile/image'), // Optionally add profile image
                    ),
                    const SizedBox(height: 9),
                    Text(
                      userDetails['userName']!,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      userDetails['userRole']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              const ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
