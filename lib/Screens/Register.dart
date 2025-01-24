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
  String? selectedRole;
  String? selectedStream;
  String? selectedBatch;
  String? selectedChildName; // For storing the selected child name
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
                    ZoomIn(child: _buildTitle()),
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
                        child: _buildBatchField(),
                      ),
                    ],
                    if (selectedRole == 'Parent')
                      FadeInUp(
                        child: _buildChildDropdown(),
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
      ['Student', 'Parent'],
          (value) {
        setState(() {
          selectedRole = value;
          selectedStream = null;
          selectedBatch = null;
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

  Widget _buildBatchField() {
    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) {
            int currentYear = DateTime.now().year;
            return AlertDialog(
              title: Text('Select Batch Year'),
              content: Container(
                width: double.maxFinite,
                height: 250,
                child: YearPicker(
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  selectedDate: selectedBatch != null
                      ? DateTime(int.parse(selectedBatch!))
                      : DateTime.now(),
                  onChanged: (DateTime dateTime) {
                    setState(() {
                      selectedBatch = dateTime.year.toString();
                    });
                    Navigator.pop(context); // Close the dialog after selection
                  },
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blueAccent),
            SizedBox(width: 16),
            Text(
              selectedBatch ?? 'Select Batch Year',
              style: TextStyle(
                color: selectedBatch == null ? Colors.white70 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No students found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final students = snapshot.data!.docs;

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
              labelText: 'Child Name',
              labelStyle: TextStyle(color: Colors.white70),
              icon: Icon(Icons.child_care, color: Colors.blueAccent),
              border: InputBorder.none,
            ),
            value: selectedChildName,
            items: students
                .map((student) {
              final data = student.data() as Map<String, dynamic>;
              final name = data['name with initial'] ?? 'Unnamed';
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            })
                .toList(),
            onChanged: (value) => setState(() => selectedChildName = value),
            style: TextStyle(color: Colors.white),
            validator: (value) =>
            value == null ? 'Please select a child name' : null,
          ),
        );
      },
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
        Customuser user = Customuser(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          nameWithInitial: nameInitialController.text.trim(),
          email: emailController.text.trim(),
          role: selectedRole,
          stream: selectedRole == 'Student' ? selectedStream : null,
          childName: selectedRole == 'Parent' ? selectedChildName : null,
          batch: selectedRole == 'Student' ? selectedBatch : null,
        );

        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );

        firstNameController.clear();
        lastNameController.clear();
        nameInitialController.clear();
        emailController.clear();
        passwordController.clear();
        setState(() {
          selectedRole = null;
          selectedStream = null;
          selectedBatch = null;
          selectedChildName = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
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