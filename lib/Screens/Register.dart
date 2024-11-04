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
  final nameInitialController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final childNameController = TextEditingController();

  String? selectedRole;
  String? selectedStream;
  String? selectedSubject;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(
            255, 5, 158, 229), // Using your specified color
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                        firstNameController, 'First Name', Icons.person),
                    _buildTextField(
                        lastNameController, 'Last Name', Icons.person),
                    _buildTextField(nameInitialController, 'Name with Initial',
                        Icons.person_outline),
                    _buildTextField(emailController, 'Email', Icons.email),
                    _buildTextField(passwordController, 'Password', Icons.lock,
                        obscureText: true),
                    _buildTextField(confirmPasswordController,
                        'Confirm Password', Icons.lock,
                        obscureText: true),
                    _buildRoleDropdown(),
                    if (selectedRole == 'Student') _buildStreamDropdown(),
                    if (selectedRole == 'Parent') _buildChildNameField(),
                    if (selectedRole == 'Teacher') _buildSubjectDropdown(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: const Color.fromARGB(
                            255, 5, 158, 229), // Using your specified color
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                color: const Color.fromARGB(
                    255, 5, 158, 229)), // Consistent icon color
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          obscureText: obscureText,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your $label'
              : null,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          value: selectedRole,
          items: ['Student', 'Teacher', 'Parent', 'Principal']
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(),
          onChanged: (value) => setState(() {
            selectedRole = value;
            selectedStream = null;
          }),
          validator: (value) => value == null ? 'Please select a role' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStreamDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stream',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          value: selectedStream,
          items: ['Physical Science', 'Biological Science']
              .map((stream) =>
                  DropdownMenuItem(value: stream, child: Text(stream)))
              .toList(),
          onChanged: (value) => setState(() => selectedStream = value),
          validator: (value) => value == null ? 'Please select a stream' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChildNameField() {
    return _buildTextField(
        childNameController, 'Child/Children\'s Name(s)', Icons.child_care);
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          value: selectedSubject,
          items: ['Biology', 'Physics', 'Chemistry', 'Combined Mathematics']
              .map((subject) =>
                  DropdownMenuItem(value: subject, child: Text(subject)))
              .toList(),
          onChanged: (value) => setState(() => selectedSubject = value),
          validator: (value) =>
              value == null ? 'Please select a subject' : null,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'name with initial': nameInitialController.text,
          'email': emailController.text,
          'role': selectedRole,
          'stream': selectedRole == 'Student' ? selectedStream : null,
          'childName':
              selectedRole == 'Parent' ? childNameController.text : null,
          'subject': selectedRole == 'Teacher' ? selectedSubject : null,
        });

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        print("Registration failed: $e");
        // Optionally show a snackbar or alert to inform the user
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nameInitialController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    childNameController.dispose();
    super.dispose();
  }
}



/*import 'package:flutter/material.dart';
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
  final childNameController = TextEditingController();
  final subjectController =
      TextEditingController(); // Keep the controller for potential use

  String? selectedRole;
  String? selectedStream;
  String? selectedSubject; // New variable for selected subject
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Login"),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(
              255, 5, 158, 229), // Set the background color
          elevation: 0, // Remove shadow for a flat design
          titleTextStyle: TextStyle(
            fontSize: 22, // Increase title size
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change text color
          )),
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
                decoration: InputDecoration(labelText: 'Name with Initial'),
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
                onChanged: (value) => setState(() {
                  selectedRole = value;
                  selectedSubject = null; // Reset subject when role changes
                }),
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Subject'),
                  value: selectedSubject,
                  items: [
                    'Biology',
                    'Physics',
                    'Chemistry',
                    'Combined Mathematics'
                  ]
                      .map((subject) => DropdownMenuItem(
                          value: subject, child: Text(subject)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedSubject = value),
                  validator: (value) =>
                      value == null ? 'Please select a subject' : null,
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
                        'subject':
                            selectedRole == 'Teacher' ? selectedSubject : null,
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
    childNameController.dispose();
    subjectController.dispose(); // Dispose of the subject controller as well
    super.dispose();
  }
}*/
