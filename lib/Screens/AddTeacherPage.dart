import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeacherPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _namewithinitialController =
      TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  Future<void> _addTeacher(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final namewithinitial = _namewithinitialController.text.trim();
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final subject = _subjectController.text.trim();

    if (email.isEmpty || password.isEmpty || namewithinitial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'firstName': firstname,
          'lastName': lastname,
          'role': 'Teacher',
          'subject': subject,
          'stream': null,
          'name with initial': namewithinitial,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher added successfully')),
        );

        _firstnameController.clear();
        _lastnameController.clear();
        _namewithinitialController.clear();
        _emailController.clear();
        _subjectController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Teacher'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Teacher Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _firstnameController,
                label: 'First Name',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _lastnameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: _namewithinitialController,
                label: 'Name with Initial',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _subjectController,
                label: 'Subject',
                icon: Icons.book,
              ),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addTeacher(context),
                  child: Text('Add Teacher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
        ),
      ),
    );
  }
}




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeacherPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _namewithinitialController =
      TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  Future<void> _addTeacher(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final namewithinitial = _namewithinitialController.text.trim();
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final subject = _subjectController.text.trim();

    if (email.isEmpty || password.isEmpty || namewithinitial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Create a new user in Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;

      if (userId != null) {
        // Add teacher details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'firstName': firstname,
          'lastName': lastname,
          'role': 'Teacher',
          'subject': subject,
          'stream': null,
          'name with initial': namewithinitial
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher added successfully')),
        );

        // Clear the text fields
        _namewithinitialController.clear();
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
              controller: _firstnameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastnameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _namewithinitialController,
              decoration: InputDecoration(labelText: 'name with initial'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Teacher Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'subject'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addTeacher(context),
              child: Text('Add Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}*/




