
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditStudentPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _namewithinitialController;

  EditStudentPage({required this.student})
      : _firstNameController =
  TextEditingController(text: student['firstName']),
        _lastNameController = TextEditingController(text: student['lastName']),
        _emailController = TextEditingController(text: student['email']),
        _namewithinitialController =
        TextEditingController(text: student['name with initial']);

  Future<void> _updateStudent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(student['id'])
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'name with initial': _namewithinitialController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namewithinitialController,
              decoration: InputDecoration(
                labelText: 'Name with Initial',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _updateStudent(context),
              icon: Icon(Icons.save),
              label: Text('Update Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}