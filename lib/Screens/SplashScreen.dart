import 'package:flutter/material.dart';
import 'dart:async'; // for Timer

class SplashScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Navigate to HomePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Adjust this to your home route
    });

    return const Scaffold(
      backgroundColor: Colors.blue, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash, // Splash logo/icon
              size: 100.0,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to My App",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
