import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTeacherPage extends StatefulWidget {
  @override
  _AddTeacherPageState createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
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
        const SnackBar(content: Text('Please fill in all required fields')),
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
          'batch': null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher added successfully')),
        );

        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteTeacher(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editTeacher(
      String userId, Map<String, dynamic> currentData, BuildContext context) {
    _firstnameController.text = currentData['firstName'] ?? '';
    _lastnameController.text = currentData['lastName'] ?? '';
    _namewithinitialController.text = currentData['name with initial'] ?? '';
    _emailController.text = currentData['email'] ?? '';
    _subjectController.text = currentData['subject'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Teacher Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                ),
                _buildTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  icon: Icons.book,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'firstName': _firstnameController.text.trim(),
                  'lastName': _lastnameController.text.trim(),
                  'name with initial': _namewithinitialController.text.trim(),
                  'email': _emailController.text.trim(),
                  'subject': _subjectController.text.trim(),
                });
                _clearFields();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Teacher details updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _firstnameController.clear();
    _lastnameController.clear();
    _namewithinitialController.clear();
    _emailController.clear();
    _subjectController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 30, thickness: 2),
            _buildTeacherList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Teacher'),
              content: SingleChildScrollView(child: _buildAddTeacherSection()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildTeacherList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Teacher')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final teachers = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            final userId = teacher.id;
            final data = teacher.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(
                  data['name with initial'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? 'N/A'}'),
                    Text('Subject: ${data['subject'] ?? 'N/A'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editTeacher(userId, data, context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTeacher(userId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddTeacherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () => _addTeacher(context),
            child: const Text('Add Teacher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
        ),
      ),
    );
  }
}