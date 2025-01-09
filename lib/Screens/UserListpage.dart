import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Services/Chatservice.dart';

class UserListPage extends StatefulWidget {
  final Customuser user;

  UserListPage({required this.user});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createOrNavigateToChat(Customuser otherUser) async {
    final chatId = ChatUtils.generateChatId(widget.user.id, otherUser.id);

    final chatQuery = await _firestore.collection('chats').doc(chatId).get();

    if (!chatQuery.exists) {
      final newChat = {
        'user1': widget.user.id,
        'user2': otherUser.id,
        'lastMessage': '',
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection('chats').doc(chatId).set(newChat);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(user: widget.user, chatId: chatId),
      ),
    );
  }

  Stream<List<Customuser>> _getUsers() {
    return _firestore
        .collection('users')
        .where(
          'role',
          whereIn: widget.user.role == 'Teacher'
              ? ['Student', 'Parent', 'Teacher']
              : ['Teacher'],
        )
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
        title: const Text(
          'Chat with Users',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 100, 183), // Dark blue
      ),
      body: StreamBuilder<List<Customuser>>(
        stream: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Something went wrong!',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data;

          if (users == null || users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No users available to chat.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _createOrNavigateToChat(user),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role ?? 'Unknown Role',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
