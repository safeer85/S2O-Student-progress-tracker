import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUpdateYoutubeLinkPage extends StatefulWidget {
  const AdminUpdateYoutubeLinkPage({Key? key}) : super(key: key);

  @override
  _AdminUpdateYoutubeLinkPageState createState() =>
      _AdminUpdateYoutubeLinkPageState();
}

class _AdminUpdateYoutubeLinkPageState
    extends State<AdminUpdateYoutubeLinkPage> {
  final TextEditingController _youtubeLinkController = TextEditingController();

  Future<void> _updateYoutubeLink() async {
    final youtubeLink = _youtubeLinkController.text.trim();
    if (youtubeLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid YouTube link')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('youtubeLink')
          .set({'url': youtubeLink});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube link updated successfully!')),
      );
    } catch (e) {
      debugPrint("Error updating YouTube link: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update YouTube link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update YouTube Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _youtubeLinkController,
              decoration: const InputDecoration(
                labelText: 'YouTube Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateYoutubeLink,
              child: const Text('Update Link'),
            ),
          ],
        ),
      ),
    );
  }
}
