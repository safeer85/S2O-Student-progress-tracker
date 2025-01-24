import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdminUpdateYoutubeLinkPage extends StatefulWidget {
  const AdminUpdateYoutubeLinkPage({Key? key}) : super(key: key);

  @override
  _AdminUpdateYoutubeLinkPageState createState() =>
      _AdminUpdateYoutubeLinkPageState();
}

class _AdminUpdateYoutubeLinkPageState
    extends State<AdminUpdateYoutubeLinkPage> {
  final TextEditingController _youtubeLinkController = TextEditingController();
  bool _isLoading = false;

  // Update the YouTube link in Firestore
  Future<void> _updateYoutubeLink() async {
    final youtubeLink = _youtubeLinkController.text.trim();

    // Validate the URL
    if (youtubeLink.isEmpty || !_isValidYoutubeUrl(youtubeLink)) {
      _showSnackBar('Please enter a valid YouTube link', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update the Firestore database
      await FirebaseFirestore.instance
          .collection('youtube_links')
          .doc('link')
          .set({'url': youtubeLink});
      _showSnackBar('YouTube link updated successfully!', Colors.green);
    } catch (e) {
      debugPrint("Error updating YouTube link: $e");
      _showSnackBar('Failed to update YouTube link', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Validate YouTube URL
  bool _isValidYoutubeUrl(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    return videoId != null;
  }

  // Show SnackBar for feedback
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update YouTube Link'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Field and Update Button
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update YouTube Link',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _youtubeLinkController,
                      decoration: InputDecoration(
                        labelText: 'YouTube Link',
                        hintText: 'Enter a valid YouTube URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _updateYoutubeLink,
                      icon: const Icon(Icons.save),
                      label: const Text('Update Link'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Real-Time YouTube Player
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('youtube_links')
                  .doc('link')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text(
                    'No video available. Update the link above.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final youtubeUrl = snapshot.data!.get('url') as String?;
                final videoId =
                YoutubePlayer.convertUrlToId(youtubeUrl ?? '');

                if (videoId == null) {
                  return const Text(
                    'Invalid YouTube link in the database.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                }

                final controller = YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current YouTube Video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}