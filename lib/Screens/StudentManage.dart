import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'EditStudentPage.dart';
import 'StudentDetailsPage.dart';

class StudentManagePage extends StatelessWidget {
  Stream<Map<String, List<Map<String, dynamic>>>> _getStudentsGroupedByBatch() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .snapshots()
        .map((snapshot) {
      Map<String, List<Map<String, dynamic>>> groupedByBatch = {};
      for (var doc in snapshot.docs) {
        final data = {
          'id': doc.id,
          'firstName': doc['firstName'],
          'lastName': doc['lastName'],
          'email': doc['email'],
          'name with initial': doc['name with initial'],
          'stream': doc['stream'],
          'batch': doc['batch'],
        };

        final batch = doc['batch'] ?? 'Unknown'; // Default batch if missing
        groupedByBatch.putIfAbsent(batch, () => []).add(data);
      }
      return groupedByBatch;
    });
  }

  void _deleteStudent(BuildContext context, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editStudent(BuildContext context, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(student: student),
      ),
    );
  }

  void _viewStudentDetails(BuildContext context, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailPage(student: student),
      ),
    );
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
        title: Text('Student Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: _getStudentsGroupedByBatch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching data',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 100, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No students found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final groupedByBatch = snapshot.data!;
          return ListView(
            padding: EdgeInsets.all(16),
            children: groupedByBatch.entries.map((entry) {
              final batch = entry.key;
              final students = entry.value;

              return Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      batch[0], // First letter of batch
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Batch: $batch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${students.length} students'),
                  children: students.map((student) {
                    return ListTile(
                      onTap: () => _viewStudentDetails(context, student),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          student['name with initial'][0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        student['name with initial'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Email: ${student['email']}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editStudent(context, student),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteStudent(context, student['id']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}