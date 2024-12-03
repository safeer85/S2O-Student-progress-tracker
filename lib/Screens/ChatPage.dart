import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:s20/Classes/Message.dart';
import 'package:s20/Classes/User.dart';

class ChatPage extends StatefulWidget {
  final Customuser user;
  final String chatId;

  ChatPage({required this.user, required this.chatId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _messageController = TextEditingController();
  String receiverName = 'Loading...';
  @override
  void initState() {
    super.initState();
    _loadReceiverName();
  }

  Future<void> _loadReceiverName() async {
    final name = await _getReceiverName();
    setState(() {
      receiverName = name;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Create a new message
      final message = Message(
        senderId: widget.user.id,
        content: _messageController.text,
        timestamp: Timestamp.now(),
      );

      // Add message to Firestore
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(message.toMap());

      // Clear the message input field
      _messageController.clear();
    }
  }

  Future<String> _getReceiverName() async {
    try {
      final chatDoc =
          await _firestore.collection('chats').doc(widget.chatId).get();

      if (chatDoc.exists) {
        final data = chatDoc.data();
        final user1Id = data?['user1'];
        final user2Id = data?['user2'];

        // Determine the receiver based on the sender
        final receiverId = (user1Id == widget.user.id) ? user2Id : user1Id;

        if (receiverId != null) {
          final userDoc =
              await _firestore.collection('users').doc(receiverId).get();
          return userDoc.data()?['name with initial'] ?? 'Unknown User';
        }
      }
      return 'Unknown User';
    } catch (e) {
      print('Error fetching receiver name: $e');
      return 'Unknown User';
    }
  }

  Stream<List<Message>> _getMessages() {
    return _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc.data()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $receiverName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data;
                if (messages == null || messages.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  itemCount: messages.length ?? 0,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.content!),
                      subtitle: Text(
                          message.senderId == widget.user.id ? 'You' : 'Other'),
                      trailing: Text(message.timestamp!.toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}