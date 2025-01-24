import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineStatusManager extends StatefulWidget {
  final String userId;

  const OnlineStatusManager({Key? key, required this.userId}) : super(key: key);

  @override
  State<OnlineStatusManager> createState() => _OnlineStatusManagerState();
}

class _OnlineStatusManagerState extends State<OnlineStatusManager>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(true); // Set online status when the app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false); // Set offline status when the widget is disposed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true); // User is active
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _setOnlineStatus(false); // User is inactive
    }
  }

  // Update Firestore with the user's online status
  Future<void> _setOnlineStatus(bool isOnline) async {
    try {
      await _firestore.collection('users').doc(widget.userId).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      debugPrint("Error updating online status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Usage Tracker")),
      body: const Center(
        child: Text("Your online status is being tracked!"),
      ),
    );
  }
}