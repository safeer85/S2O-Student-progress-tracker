import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:s20/Classes/User.dart';
import 'ChatPage.dart';

class PrincipalDashboard extends StatefulWidget {
  final Customuser user;

  const PrincipalDashboard({required this.user});

  @override
  _PrincipalDashboardState createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // For demo purposes only. Use Firebase Auth in production.

  Future<void> _addTeacher() async {
    if (_emailController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      // Add teacher to Firestore
      await _firestore.collection('users').add({
        'email': _emailController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'role': 'teacher',
        'password': _passwordController
            .text, // For demo purposes. Hash passwords in production.
      });

      // Clear input fields
      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _passwordController.clear();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teacher added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  Stream<List<Customuser>> _getTeachers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customuser.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Principal Dashboard'),
      ),
      body: Column(
        children: [
          // Add Teacher Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Teacher',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addTeacher,
                  child: Text('Add Teacher'),
                ),
              ],
            ),
          ),

          // Teacher List Section
          Expanded(
            child: StreamBuilder<List<Customuser>>(
              stream: _getTeachers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final teachers = snapshot.data;

                return ListView.builder(
                  itemCount: teachers?.length ?? 0,
                  itemBuilder: (context, index) {
                    final teacher = teachers![index];
                    return ListTile(
                      title: Text('${teacher.firstName} ${teacher.lastName}'),
                      subtitle: Text(teacher.email ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.message),
                        onPressed: () {
                          // Navigate to chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                user: widget.user,
                                chatId:
                                    _generateChatId(widget.user.id, teacher.id),
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
          ),
        ],
      ),
    );
  }

  // Generate chat ID function
  String _generateChatId(String? userId1, String? userId2) {
    final sortedIds = [userId1!, userId2!]..sort();
    return sortedIds.join('_');
  }
}
