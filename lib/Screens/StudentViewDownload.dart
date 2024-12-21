import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:s20/Classes/SharedResource.dart';
import 'package:s20/Classes/User.dart';

class StudentViewDownloadPage extends StatelessWidget {
  final Customuser user;

  const StudentViewDownloadPage({required this.user, Key? key})
      : super(key: key);

  Future<List<SharedResource>> _fetchSharedResources() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sharedResources')
        .where('batch', isEqualTo: user.batch)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SharedResource.fromFirestore(doc))
        .toList();
  }

  Future<void> _downloadFile(String fileUrl) async {
    final Uri fileUri = Uri.parse(fileUrl);
    if (await canLaunchUrl(fileUri)) {
      await launchUrl(fileUri);
    } else {
      throw 'Could not launch $fileUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Resources'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<SharedResource>>(
        future: _fetchSharedResources(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text('Error loading resources. Please try again.'),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No resources available for your batch.'),
                ],
              ),
            );
          }

          final resources = snapshot.data!;
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      resource.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          resource.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Shared on: ${resource.timestamp is Timestamp ? (resource.timestamp as Timestamp).toDate().toString() : resource.timestamp?.toString() ?? 'Unknown date'}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _downloadFile(resource.fileUrl),
                      icon: Icon(Icons.download, color: Colors.white),
                      label: Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}








/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:s20/Classes/SharedResource.dart';
import 'package:s20/Classes/User.dart';

class StudentViewDownloadPage extends StatelessWidget {
  final Customuser user;

  const StudentViewDownloadPage({required this.user, Key? key})
      : super(key: key);

  Future<List<SharedResource>> _fetchSharedResources() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sharedResources')
        .where('batch', isEqualTo: user.batch)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SharedResource.fromFirestore(doc))
        .toList();
  }

  Future<void> _downloadFile(String fileUrl) async {
    final Uri fileUri = Uri.parse(fileUrl);
    if (await canLaunchUrl(fileUri)) {
      await launchUrl(fileUri);
    } else {
      throw 'Could not launch $fileUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Resources')),
      body: FutureBuilder<List<SharedResource>>(
        future: _fetchSharedResources(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No resources available'));
          }

          final resources = snapshot.data!;
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                child: ListTile(
                  title: Text(resource.title),
                  subtitle: Text(resource.description),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () => _downloadFile(resource.fileUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}*/
