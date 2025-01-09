import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Screens/Login.dart';

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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF0F1B2B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.blueAccent)
                  : Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ZoomIn(
                            child: _buildTitle(),
                          ),
                          SizedBox(height: 20),
                          FadeInLeft(
                            child: _buildGlassCard(
                              'First Name',
                              firstNameController,
                              Icons.person,
                            ),
                          ),
                          FadeInRight(
                            child: _buildGlassCard(
                              'Last Name',
                              lastNameController,
                              Icons.person_outline,
                            ),
                          ),
                          FadeInLeft(
                            child: _buildGlassCard(
                              'Name with Initial',
                              nameInitialController,
                              Icons.text_fields,
                            ),
                          ),
                          FadeInRight(
                            child: _buildGlassCard(
                              'Email',
                              emailController,
                              Icons.email_outlined,
                            ),
                          ),
                          FadeInLeft(
                            child: _buildGlassCard(
                              'Password',
                              passwordController,
                              Icons.lock_outline,
                              obscureText: true,
                            ),
                          ),
                          FadeInRight(
                            child: _buildGlassCard(
                              'Confirm Password',
                              confirmPasswordController,
                              Icons.lock,
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 10),
                          BounceInUp(child: _buildRoleDropdown()),
                          if (selectedRole == 'Student') ...[
                            FadeInUp(
                              child: _buildStreamDropdown(),
                            ),
                            FadeInUp(
                              child: _buildBatchDropdown(),
                            ),
                          ],
                          if (selectedRole == 'Parent')
                            FadeInUp(
                              child: _buildGlassCard(
                                'Child Name',
                                childNameController,
                                Icons.child_care,
                              ),
                            ),
                          SizedBox(height: 30),
                          SlideInUp(
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Icon(Icons.person_add_alt, size: 80, color: Colors.blueAccent),
        SizedBox(height: 16),
        Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(
      String label, TextEditingController controller, IconData icon,
      {bool obscureText = false}) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: InputBorder.none,
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
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
      Icons.timeline,
      selectedBatch,
      ['2030', '2029', '2028', '2027'],
      (value) => setState(() => selectedBatch = value),
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? value,
      List<String> items, void Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.black,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          icon: Icon(icon, color: Colors.blueAccent),
          border: InputBorder.none,
        ),
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        style: TextStyle(color: Colors.white),
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
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

        //Registration success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );

        // Clear the text fields
        firstNameController.clear();
        lastNameController.clear();
        nameInitialController.clear();
        emailController.clear();
        passwordController.clear();
        childNameController.clear();
        setState(() {
          selectedRole = null;
          selectedStream = null;
          selectedBatch = null;
        });
        Navigator.pop(context, true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        //setState(() => _userDetails = fetchUserDetails());
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
