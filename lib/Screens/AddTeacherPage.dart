import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeacherPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _addTeacher() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isNotEmpty && name.isNotEmpty) {
      // Add teacher to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'firstName': name.split(' ')[0],
        'lastName': name.split(' ')[1] ?? '',
        'role': 'teacher',
        'subject': null,
        'stream': null,
      });
      print('Teacher added successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Teacher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Teacher Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Teacher Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTeacher,
              child: Text('Add Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}
