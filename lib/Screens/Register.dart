import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final Name_initialController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final streamController = TextEditingController();
  final childNameController = TextEditingController();
  final subjectController = TextEditingController();

  String? selectedRole;
  String? selectedStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your first name'
                    : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your last name'
                    : null,
              ),
              TextFormField(
                controller: Name_initialController,
                decoration: InputDecoration(labelText: 'Name with initial'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your username'
                    : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty || !value.contains('@')
                        ? 'Please enter a valid email'
                        : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty || value.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) => value != passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Role'),
                value: selectedRole,
                items: ['Student', 'Teacher', 'Parent', 'Principal']
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value),
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),
              if (selectedRole == 'Student')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Stream'),
                  value: selectedStream,
                  items: ['Physical Science', 'Biological Science']
                      .map((stream) =>
                          DropdownMenuItem(value: stream, child: Text(stream)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedStream = value),
                  validator: (value) =>
                      value == null && selectedRole == 'Student'
                          ? 'Please select a stream'
                          : null,
                ),
              if (selectedRole == 'Parent')
                TextFormField(
                  controller: childNameController,
                  decoration:
                      InputDecoration(labelText: 'Child/Children\'s Name(s)'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your child\'s or children\'s name(s)'
                      : null,
                ),
              if (selectedRole == 'Teacher')
                TextFormField(
                  controller: subjectController,
                  decoration: InputDecoration(labelText: 'Subject'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the subject you teach'
                      : null,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Create user in Firebase Authentication
                      UserCredential userCredential =
                          await _auth.createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // Save additional user information in Firestore
                      await _firestore
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'firstName': firstNameController.text,
                        'lastName': lastNameController.text,
                        'name with initial': Name_initialController.text,
                        'email': emailController.text,
                        'role': selectedRole,
                        'stream':
                            selectedRole == 'Student' ? selectedStream : null,
                        'childName': selectedRole == 'Parent'
                            ? childNameController.text
                            : null,
                        'subject': selectedRole == 'Teacher'
                            ? subjectController.text
                            : null,
                      });

                      print(
                          "Registration successful and data saved in Firestore!");
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      print("Registration failed: $e");
                    }
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    Name_initialController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    streamController.dispose();
    childNameController.dispose();
    subjectController.dispose();
    super.dispose();
  }
}
