import 'package:flutter/material.dart';

import '../Classes/User.dart';
import 'ChatPage.dart';

class TeacherListPage extends StatelessWidget {
  final Stream<List<Customuser>> Function() getTeachersStream;
  final Customuser currentUser;
  final String Function(String?, String?) generateChatId;

  const TeacherListPage({
    required this.getTeachersStream,
    required this.currentUser,
    required this.generateChatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Teachers'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Customuser>>(
        stream: getTeachersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          }

          final teachers = snapshot.data;

          if (teachers == null || teachers.isEmpty) {
            return Center(
              child: Text(
                'No teachers available.',
                style: TextStyle(fontSize: 18, color: Colors.teal.shade700),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.person, color: Colors.teal.shade700),
                  ),
                  title: Text(
                    '${teacher.firstName} ${teacher.lastName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  subtitle: Text(
                    teacher.email ?? 'No email provided',
                    style: TextStyle(color: Colors.teal.shade500),
                  ),
                  trailing: Icon(
                    Icons.message,
                    color: Colors.teal.shade700,
                  ),
                  onTap: () {
                    final chatId = generateChatId(currentUser.id, teacher.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          user: currentUser,
                          chatId: chatId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}