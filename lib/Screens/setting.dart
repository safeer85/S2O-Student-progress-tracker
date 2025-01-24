import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nameWithInitialController =
  TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  late String _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get the current logged-in user's ID from FirebaseAuth
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (_userId.isNotEmpty) {
      _loadUserData();
    }
  }

  // Load current user data from Firestore
  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _nameWithInitialController.text = data['name with initial'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }
  Future<void> reauthenticateUser(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No user is logged in.");
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print("Re-authentication successful");
    } catch (e) {
      throw Exception("Re-authentication failed: $e");
    }
  }
  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw Exception("No user is logged in.");
        }

        // Re-authenticate the user
        await reauthenticateUser(user.email!, _passwordController.text);

        // Update the email
        if (_emailController.text.isNotEmpty &&
            _emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
          print("Email updated successfully.");
        }

        // Update the password
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text) {
          await user.updatePassword(_passwordController.text);
          print("Password updated successfully.");
        }

        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'name with initial': _nameWithInitialController.text,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Log out the user
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(_firstNameController, 'First Name'),
              const SizedBox(height: 16),
              _buildTextFormField(_lastNameController, 'Last Name'),
              const SizedBox(height: 16),
              _buildTextFormField(
                  _nameWithInitialController, 'Name with Initial'),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
            .hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'New Password',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.length < 6) {
          return 'Password should be at least 6 characters';
        }
        return null;
      },
    );
  }

  TextFormField _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (_passwordController.text != value) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}