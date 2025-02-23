import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s20/Screens/Login.dart';

class ManageAdminsPage extends StatefulWidget {
  @override
  _ManageAdminsPageState createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameWithInitialController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<void> _addAdmin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nameWithInitial = _nameWithInitialController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty || password.isEmpty || nameWithInitial.isEmpty) {
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
          'name with initial': nameWithInitial,
          'role': 'Admin',
          'firstName': firstName,
          'lastName': lastName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin added successfully')),
        );

        _clearFields();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ); // Close the dialog after adding the admin
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameWithInitialController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
  }

  void _editAdmin(
      BuildContext context, String userId, Map<String, dynamic> adminData) {
    final TextEditingController editEmailController =
        TextEditingController(text: adminData['email']);
    final TextEditingController editNameController =
        TextEditingController(text: adminData['name with initial']);
    final TextEditingController editFirstNameController =
        TextEditingController(text: adminData['firstName']);
    final TextEditingController editLastNameController =
        TextEditingController(text: adminData['lastName']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Admin'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                  controller: editFirstNameController,
                  label: 'First Name',
                  icon: Icons.person),
              _buildTextField(
                  controller: editLastNameController,
                  label: 'Last Name',
                  icon: Icons.person),
              _buildTextField(
                  controller: editNameController,
                  label: 'Name',
                  icon: Icons.person),
              _buildTextField(
                  controller: editEmailController,
                  label: 'Email',
                  icon: Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'email': editEmailController.text.trim(),
                  'name with initial': editNameController.text.trim(),
                  'firstName': editFirstNameController.text.trim(),
                  'lastName': editLastNameController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Admin details updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Redirect to login if no user is logged in
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admins'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 30, thickness: 2),
            _buildAdminList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Admin'),
              content: SingleChildScrollView(child: _buildAddAdminSection()),
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

  Widget _buildAddAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person,
        ),
        _buildTextField(
          controller: _lastNameController,
          label: ' Last Name',
          icon: Icons.person,
        ),
        _buildTextField(
          controller: _nameWithInitialController,
          label: 'Name with initial',
          icon: Icons.person,
        ),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
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
            onPressed: () => _addAdmin(context),
            child: const Text('Add Admin'),
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

  Widget _buildAdminList() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final admins = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: admins.length,
          itemBuilder: (context, index) {
            final admin = admins[index];
            final userId = admin.id;
            final data = admin.data() as Map<String, dynamic>;

            // Check if this admin is the logged-in admin
            final isCurrentUser =
                currentUser != null && currentUser.uid == userId;

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
                    if (isCurrentUser) const Text('(Logged-in Admin)'),
                  ],
                ),
                trailing: isCurrentUser
                    ? null // Prevent logged-in admin from being deleted
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editAdmin(context, userId, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Admin deleted successfully')),
                              );
                            },
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
