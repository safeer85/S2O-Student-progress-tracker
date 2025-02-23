import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineUsersPage extends StatelessWidget {
  const OnlineUsersPage({Key? key}) : super(key: key);

  // Fetch users who are currently online
  Stream<List<Map<String, dynamic>>> getOnlineUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList());
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Users"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOnlineUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No users are currently online"),
            );
          }
          final onlineUsers = snapshot.data!;
          return ListView.builder(
            itemCount: onlineUsers.length,
            itemBuilder: (context, index) {
              final user = onlineUsers[index];
              return ListTile(
                title: Text(user['firstName'] ?? 'Unknown User'),
                subtitle: Text(user['email'] ?? 'No Email'),
                trailing: const Icon(Icons.circle, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}