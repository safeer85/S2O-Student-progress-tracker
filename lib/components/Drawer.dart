/*import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  // backgroundImage: AssetImage(
                  // 'path/to/profile/image'), // Update with the user's profile image path
                ),
                SizedBox(height: 10),
                Text(
                  'User Name', // Replace with dynamic user name
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Role', // Replace with dynamic user role
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          /*DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),*/
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            //onTap: () {
            // Navigator.pushNamed(context, '/feedback');
            //},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            //onTap: () {
            // Navigator.pushNamed(context, '/help');
            //},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Ensures the column only takes the space it needs
              children: [
                CircleAvatar(
                  radius: 35,
                  // backgroundImage: AssetImage('path/to/profile/image'), // Optionally add profile image
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name', // Replace with dynamic user name
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Text(
                  'Role', // Replace with dynamic user role
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            // onTap: () { Navigator.pushNamed(context, '/feedback'); },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            // onTap: () { Navigator.pushNamed(context, '/help'); },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login screen or perform any other necessary actions after logout
              Navigator.pushReplacementNamed(
                  context, '/login'); // Assuming '/login' is your login route
            },
          ),
        ],
      ),
    );
  }
}
