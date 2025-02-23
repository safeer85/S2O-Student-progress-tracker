import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
        .get();

    return snapshot.docs
        .map((doc) => SharedResource.fromFirestore(doc))
        .toList();
  }

  /*Future<void> _downloadFile(
      BuildContext context, String fileUrl, String fileName) async {
    try {
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        final directory = await _getDownloadDirectory();
        if (directory != null) {
          // Ensure the file name ends with .pdf
          if (!fileName.toLowerCase().endsWith('.pdf')) {
            fileName = '$fileName.pdf';
          }
          // final savePath = "${directory.path}/$fileName";

          // Start the download
          await FlutterDownloader.enqueue(
            url: fileUrl,
            savedDir: directory.path,
            fileName: fileName,
            showNotification: true,
            openFileFromNotification: true,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download started: $fileName')),
          );
        } else {
          throw 'Could not access storage directory';
        }
      } else if (storagePermission.isPermanentlyDenied) {
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enable storage permissions in settings.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download the file')),
      );
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        // For Android 11 and above
        return await getExternalStorageDirectories(
                type: StorageDirectory.downloads)
            .then((dirs) => dirs?.first);
      } else {
        // For Android 10 and below
        return await getExternalStorageDirectory();
      }
    }
    return null; // You can add support for iOS or other platforms here if needed
  }*/
  Future<void> _downloadFile(
      BuildContext context, String fileUrl, String fileName) async {
    try {
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        final directory = await _getDownloadDirectory();
        if (directory != null) {
          // Ensure the file name ends with .pdf
          if (!fileName.toLowerCase().endsWith('.pdf')) {
            fileName = '$fileName.pdf';
          }

          final savePath = "${directory.path}/$fileName";

          // Check if the file already exists
          if (await File(savePath).exists()) {
            // File already exists, open it
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('File already downloaded, opening: $fileName')),
            );
            _openFile(savePath); // Open the file
          } else {
            // Start the download
            await FlutterDownloader.enqueue(
              url: fileUrl,
              savedDir: directory.path,
              fileName: fileName,
              showNotification: true,
              openFileFromNotification: true,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download started: $fileName')),
            );
          }
        } else {
          throw 'Could not access storage directory';
        }
      } else if (storagePermission.isPermanentlyDenied) {
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enable storage permissions in settings.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download the file')),
      );
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        // For Android 11 and above
        return await getExternalStorageDirectories(
                type: StorageDirectory.downloads)
            .then((dirs) => dirs?.first);
      } else {
        // For Android 10 and below
        return await getExternalStorageDirectory();
      }
    }
    return null; // You can add support for iOS or other platforms here if needed
  }

  void _openFile(String filePath) {
    // Use an appropriate method to open the file depending on your app requirements
    // For example, you can use the `open_file` package or `url_launcher` package to open the file
    // Example:
    OpenFile.open(filePath);
    // or use any other file viewer/handler in your app.
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
        title: Text('View Resources'),
        backgroundColor: const Color.fromARGB(255, 44, 100, 183),
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
                      onPressed: () => _downloadFile(
                          context, resource.fileUrl, resource.title),
                      icon: Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Download',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 44, 100, 183),
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
