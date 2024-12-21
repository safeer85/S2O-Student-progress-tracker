import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:s20/Classes/User.dart';

class TeacherResourceSharePage extends StatefulWidget {
  final Customuser user;

  const TeacherResourceSharePage({required this.user, Key? key})
      : super(key: key);

  @override
  _TeacherResourceSharePageState createState() =>
      _TeacherResourceSharePageState();
}

class _TeacherResourceSharePageState extends State<TeacherResourceSharePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? uploadedFileUrl;
  String? selectedFileType;
  String? selectedBatch;
  bool isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      setState(() => isUploading = true);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('sharedResources/${widget.user.id}/$fileName');
      await storageRef.putFile(file);

      String fileUrl = await storageRef.getDownloadURL();
      setState(() {
        uploadedFileUrl = fileUrl;
        selectedFileType = fileName.endsWith('.pdf') ? 'PDF' : 'Image';
        isUploading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('File uploaded successfully')));
    }
  }

  Future<void> _shareResource() async {
    if (titleController.text.isEmpty ||
        uploadedFileUrl == null ||
        selectedBatch == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please complete all fields')));
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('sharedResources').doc();
    await docRef.set({
      'teacherId': widget.user.id,
      'timestamp': FieldValue.serverTimestamp(),
      'fileType': selectedFileType,
      'fileUrl': uploadedFileUrl,
      'title': titleController.text,
      'description': descriptionController.text,
      'targetAudience': ['students'],
      'batch': selectedBatch,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Resource shared successfully')));
    titleController.clear();
    descriptionController.clear();
    setState(() {
      uploadedFileUrl = null;
      selectedFileType = null;
      selectedBatch = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share Resource')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Resource Details'),
            _buildTextField(
              controller: titleController,
              labelText: 'Title',
              hintText: 'Enter resource title',
            ),
            _buildTextField(
              controller: descriptionController,
              labelText: 'Description',
              hintText: 'Enter resource description',
            ),
            _buildSectionTitle('Target Audience'),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Batch',
              ),
              value: selectedBatch,
              onChanged: (value) => setState(() => selectedBatch = value),
              items: [
                '2030',
                '2029',
                '2028',
                '2027',
                '2026',
                '2025',
                '2024',
                '2023'
              ]
                  .map((batch) =>
                      DropdownMenuItem(value: batch, child: Text(batch)))
                  .toList(),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('Upload File'),
            ElevatedButton.icon(
              onPressed: isUploading ? null : _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text(isUploading ? 'Uploading...' : 'Upload File'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            if (uploadedFileUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'File Uploaded: ${uploadedFileUrl!.split('/').last}',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isUploading ? null : _shareResource,
              child: Text('Share Resource'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
        ),
      ),
    );
  }
}




/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:s20/Classes/User.dart';

class TeacherResourceSharePage extends StatefulWidget {
  final Customuser user;

  const TeacherResourceSharePage({required this.user, Key? key})
      : super(key: key);

  @override
  _TeacherResourceSharePageState createState() =>
      _TeacherResourceSharePageState();
}

class _TeacherResourceSharePageState extends State<TeacherResourceSharePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? uploadedFileUrl;
  String? selectedFileType;
  String? selectedBatch;
  String? selectedStream;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('sharedResources/${widget.user.id}/$fileName');
      await storageRef.putFile(file);

      String fileUrl = await storageRef.getDownloadURL();
      setState(() {
        uploadedFileUrl = fileUrl;
        selectedFileType = fileName.endsWith('.pdf') ? 'PDF' : 'Image';
      });
    }
  }

  Future<void> _shareResource() async {
    if (titleController.text.isEmpty ||
        uploadedFileUrl == null ||
        selectedBatch == null ||
        selectedStream == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please complete all fields')));
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('sharedResources').doc();
    await docRef.set({
      'teacherId': widget.user.id,
      'timestamp': FieldValue.serverTimestamp(),
      'fileType': selectedFileType,
      'fileUrl': uploadedFileUrl,
      'title': titleController.text,
      'description': descriptionController.text,
      'targetAudience': ['students'],
      'batch': selectedBatch,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Resource shared successfully')));
    titleController.clear();
    descriptionController.clear();
    setState(() {
      uploadedFileUrl = null;
      selectedFileType = null;
      selectedBatch = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share Resource')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              hint: Text('Select Batch'),
              value: selectedBatch,
              onChanged: (value) => setState(() => selectedBatch = value),
              items: [
                '2030',
                '2029',
                '2028',
                '2027',
                '2026',
                '2025',
                '2024',
                '2023'
              ]
                  .map((batch) =>
                      DropdownMenuItem(value: batch, child: Text(batch)))
                  .toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Upload File'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _shareResource,
              child: Text('Share'),
            ),
            if (uploadedFileUrl != null) Text('File uploaded successfully'),
          ],
        ),
      ),
    );
  }
}*/
