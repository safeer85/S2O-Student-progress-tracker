import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:s20/Classes/User.dart'; // Import your User class

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nameInitialController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final childNameController = TextEditingController();

  String? selectedRole;
  String? selectedStream;
  String? selectedBatch;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFD7E1EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ZoomIn(child: _buildTitle()),
                      FadeInUp(
                        delay: Duration(milliseconds: 200),
                        child: _buildCard(
                            'First Name', firstNameController, Icons.person),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 300),
                        child: _buildCard(
                            'Last Name', lastNameController, Icons.person),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 400),
                        child: _buildCard('Name with Initial',
                            nameInitialController, Icons.person_outline),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 500),
                        child:
                            _buildCard('Email', emailController, Icons.email),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 600),
                        child: _buildCard(
                            'Password', passwordController, Icons.lock,
                            obscureText: true),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 700),
                        child: _buildCard('Confirm Password',
                            confirmPasswordController, Icons.lock,
                            obscureText: true),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 800),
                        child: _buildRoleDropdown(),
                      ),
                      if (selectedRole == 'Student') ...[
                        FadeInUp(
                          delay: Duration(milliseconds: 900),
                          child: _buildStreamDropdown(),
                        ),
                        FadeInUp(
                          delay: Duration(milliseconds: 1000),
                          child:
                              _buildBatchDropdown(), // Add batch dropdown here
                        ),
                      ],
                      if (selectedRole == 'Parent')
                        FadeInUp(
                          delay: Duration(milliseconds: 1000),
                          child: _buildChildNameField(),
                        ),
                      SizedBox(height: 20),
                      Bounce(
                        delay: Duration(milliseconds: 1200),
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 5,
                            backgroundColor: Color(0xFF5B86E5),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Icon(Icons.app_registration, size: 80, color: Color(0xFF5B86E5)),
        SizedBox(height: 16),
        Text(
          "Register Account",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCard(
      String label, TextEditingController controller, IconData icon,
      {bool obscureText = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Color(0xFF5B86E5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your $label'
              : null,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return _buildDropdown(
      'Role',
      Icons.people,
      selectedRole,
      [
        'Student',
        'Parent',
        'Admin',
      ],
      (value) {
        setState(() {
          selectedRole = value;
          selectedStream = null;
        });
      },
    );
  }

  Widget _buildStreamDropdown() {
    return _buildDropdown(
      'Stream',
      Icons.school,
      selectedStream,
      ['Physical Science', 'Biological Science'],
      (value) => setState(() => selectedStream = value),
    );
  }

  Widget _buildBatchDropdown() {
    return _buildDropdown(
      'Batch',
      Icons.school_outlined,
      selectedBatch,
      [
        '2030',
        '2029',
        '2028',
        '2027',
        '2026',
        '2025',
        '2024',
        '2023'
      ], // List of batches
      (value) => setState(() => selectedBatch = value),
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? value,
      List<String> items, void Function(String?) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Color(0xFF5B86E5)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select a $label' : null,
        ),
      ),
    );
  }

  Widget _buildChildNameField() {
    return _buildCard(
        'Child/Children\'s Name(s)', childNameController, Icons.child_care);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Create a User object from the form data
        Customuser user = Customuser(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          nameWithInitial: nameInitialController.text.trim(),
          email: emailController.text.trim(),
          role: selectedRole,
          stream: selectedRole == 'Student' ? selectedStream : null,
          childName:
              selectedRole == 'Parent' ? childNameController.text.trim() : null,
          batch: selectedRole == 'Student' ? selectedBatch : null,
        );

        // Register the user using Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Store the User object data in Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toFirestore());

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
