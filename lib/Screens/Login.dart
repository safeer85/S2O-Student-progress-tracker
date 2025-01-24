import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:s20/Screens/Home.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Screens/PrincipalDashboard.dart';
import 'dart:developer';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      log('Attempting login with email: ${emailController.text}');
      setState(() {
        isLoading = true;
      });
      try {
        // Authenticate the user
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Fetch user document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          // Parse user document
          Customuser customUser = Customuser.fromFirestore(
            userDoc.data() as Map<String, dynamic>,
            userDoc.id,
          );

          // Update isOnline status
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'isOnline': true});

          // Navigate to appropriate dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => customUser.role == 'Admin'
                  ? AdminDashboard(user: customUser)
                  : HomePage(user: customUser),
            ),
          );
        } else {
          throw Exception('User data not found');
        }
      } catch (e) {
        log('Login failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.blue.shade900, Colors.black],
                center: Alignment.topCenter,
                radius: 2,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              // Added for scrolling
              child: ZoomIn(
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeInDown(
                              child: Image.asset('assets/images/logo.png',
                                  height: 70)),
                          SizedBox(height: 20),
                          FadeInLeft(
                            child: Text(
                              'Hello, Welcome Back!',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text('Sign in with your account',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70)),
                          SizedBox(height: 30),
                          SlideInUp(
                            child: TextFormField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon:
                                    Icon(Icons.email, color: Colors.white),
                                filled: true,
                                fillColor: Colors.white24,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          SlideInUp(
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.white),
                                filled: true,
                                fillColor: Colors.white24,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          FlipInX(
                            child: isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: loginUser,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 100),
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.blue.shade900, Colors.black],
                center: Alignment.topCenter,
                radius: 2,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ZoomIn(
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeInDown(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 70,
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInLeft(
                          child: Text(
                            'Hello, Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Sign in with your account',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 30),
                        SlideInUp(
                          child: TextFormField(
                            controller: emailController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.email, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        SlideInUp(
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.lock, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        FlipInX(
                          child: isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100), backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
