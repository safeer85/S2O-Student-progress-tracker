import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart'; // Import the ChatPage to navigate to the chat
import 'package:s20/Classes/User.dart'; // Your Customuser model

class UserListPage extends StatefulWidget {
  final Customuser user;

  UserListPage({required this.user});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createOrNavigateToChat(Customuser otherUser) async {
    // Check if chat room already exists
    final chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('user1', isEqualTo: widget.user.id)
        .where('user2', isEqualTo: otherUser.id)
        .get();

    if (chatQuery.docs.isEmpty) {
      // Create new chat room if not exists
      final newChat = {
        'user1': widget.user.id,
        'user2': otherUser.id,
        'timestamp': Timestamp.now(),
      };

      // Add the new chat room
      final chatDoc =
          await FirebaseFirestore.instance.collection('chats').add(newChat);

      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(user: widget.user, chatId: chatDoc.id),
        ),
      );
    } else {
      // Navigate to existing chat room
      final existingChatId = chatQuery.docs.first.id;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatPage(user: widget.user, chatId: existingChatId),
        ),
      );
    }
  }

  // Fetch the list of users (students, teachers, etc.)
  Stream<List<Customuser>> _getUsers() {
    return _firestore
        .collection('users')
        .where('role', isNotEqualTo: widget.user.role) // Exclude current user
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Customuser.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Users'),
      ),
      body: StreamBuilder<List<Customuser>>(
        stream: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          final users = snapshot.data;

          return ListView.builder(
            itemCount: users?.length ?? 0,
            itemBuilder: (context, index) {
              final user = users![index];

              return ListTile(
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.role ?? 'Unknown Role'),
                onTap: () {
                  _createOrNavigateToChat(user); // Call to start or join chat
                },
              );
            },
          );
        },
      ),
    );
  }
}
