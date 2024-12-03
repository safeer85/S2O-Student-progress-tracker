import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTeachersPage extends StatelessWidget {
  Stream<List<Map<String, dynamic>>> _getTeachers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> _deleteTeacher(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(id).delete();
    print('Teacher deleted successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Teachers'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final teachers = snapshot.data ?? [];

          if (teachers.isEmpty) {
            return Center(child: Text('No teachers found.'));
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return ListTile(
                title: Text(teacher['firstName'] + ' ' + teacher['lastName']),
                subtitle: Text(teacher['email']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteTeacher(teacher['id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
