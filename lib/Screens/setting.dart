/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _nameWithInitialController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

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
  _loadUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _nameWithInitialController.text = data['name with initial'] ?? '';
      _emailController.text = data['email'] ?? '';
    }
  }

  // Save the updated user data
  _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'name with initial': _nameWithInitialController.text,
          'email': _emailController.text,
        });

        // Update Firebase Authentication details (email and password)
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text) {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Verify the email before updating
            await user.verifyBeforeUpdateEmail(_emailController.text);

            // If the email is verified, update the password
            await user.updatePassword(_passwordController.text);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('User data updated successfully!'),
            backgroundColor: Colors.green));

        // Sign out the user and prompt them to log in again
        await FirebaseAuth.instance.signOut();

        // Navigate back to login page
        Navigator.pushReplacementNamed(
            context, '/login'); // Adjust route as per your app's navigation
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update user data. Please try again.'),
            backgroundColor: Colors.red));
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
        title: Text('Settings'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
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
              _buildTextFormField(_lastNameController, 'Last Name'),
              _buildTextFormField(
                  _nameWithInitialController, 'Name with Initial'),
              _buildEmailField(),
              _buildPasswordField(),
              _buildConfirmPasswordField(),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateUserData,
                      child: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
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
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
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
      decoration: InputDecoration(
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
      decoration: InputDecoration(
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
      decoration: InputDecoration(
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
}*/

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
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _nameWithInitialController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

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
  _loadUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _nameWithInitialController.text = data['name with initial'] ?? '';
      _emailController.text = data['email'] ?? '';
    }
  }

  // Save the updated user data
  _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'name with initial': _nameWithInitialController.text,
          'email': _emailController.text,
        });

        // Update Firebase Authentication details (email and password)
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text) {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Verify the email before updating
            await user.verifyBeforeUpdateEmail(_emailController.text);

            // If the email is verified, update the password
            await user.updatePassword(_passwordController.text);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('User data updated successfully!'),
            backgroundColor: Colors.green));

        // Sign out the user and prompt them to log in again
        await FirebaseAuth.instance.signOut();

        // Navigate back to login page
        Navigator.pushReplacementNamed(
            context, '/login'); // Adjust route as per your app's navigation
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update user data. Please try again.'),
            backgroundColor: Colors.red));
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
        title: Text('Settings'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading text below AppBar
            Text(
              'Change Your Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20), // Spacing before form fields

            // Form with fields
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextFormField(_firstNameController, 'First Name'),
                    _buildTextFormField(_lastNameController, 'Last Name'),
                    _buildTextFormField(
                        _nameWithInitialController, 'Name with Initial'),
                    _buildEmailField(),
                    _buildPasswordField(),
                    _buildConfirmPasswordField(),
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _updateUserData,
                            child: Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              textStyle: TextStyle(fontSize: 16),
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
          ],
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
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
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
      decoration: InputDecoration(
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
      decoration: InputDecoration(
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
      decoration: InputDecoration(
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
