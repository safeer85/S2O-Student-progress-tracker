import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentManagePage extends StatelessWidget {
  // Fetch students from Firestore where role is 'Student'
  Stream<List<Map<String, dynamic>>> _getStudents() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'firstName': doc['firstName'],
                  'lastName': doc['lastName'],
                  'email': doc['email'],
                  'name with initial': doc['name with initial'],
                  'stream': doc['stream'],
                })
            .toList());
  }

  // Function to delete a student
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

  // Navigate to the edit page
  void _editStudent(BuildContext context, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
        backgroundColor: Color(0xFF3A86FF),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found'));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(student['name with initial'][0]),
                  ),
                  title: Text(
                    student['name with initial'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Email: ${student['email']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editStudent(context, student),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStudent(context, student['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Student Page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EditStudentPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _namewithinitialController;

  EditStudentPage({required this.student})
      : _firstNameController =
            TextEditingController(text: student['firstName']),
        _lastNameController = TextEditingController(text: student['lastName']),
        _emailController = TextEditingController(text: student['email']),
        _namewithinitialController =
            TextEditingController(text: student['name with initial']);

  Future<void> _updateStudent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(student['id'])
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'name with initial': _namewithinitialController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
        backgroundColor: Color(0xFF3A86FF),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namewithinitialController,
              decoration: InputDecoration(
                labelText: 'Name with Initial',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _updateStudent(context),
              icon: Icon(Icons.save),
              label: Text('Update Student'),
            ),
          ],
        ),
      ),
    );
  }
}



/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentManagePage extends StatelessWidget {
  // Fetch students from Firestore where role is 'Student'
  Stream<List<Map<String, dynamic>>> _getStudents() {
    return FirebaseFirestore.instance
        .collection('users') // Reference to the users collection
        .where('role', isEqualTo: 'Student') // Filter by role 'Student'
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'firstName': doc['firstName'],
                  'lastName': doc['lastName'],
                  'email': doc['email'],
                  'name with initial': doc['name with initial'],
                  'stream': doc['stream'],
                  // Add other student fields if needed
                })
            .toList());
  }

  // Function to delete a student
  void _deleteStudent(BuildContext context, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student')),
      );
    }
  }

  // Function to navigate to the edit page
  void _editStudent(BuildContext context, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found'));
          }

          final students = snapshot.data!;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${student['name with initial']} '),
                  subtitle: Text('Email: ${student['email']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editStudent(context, student),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(context, student['id']),
                      ),
                    ],
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

class EditStudentPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _namewithinitialController;

  EditStudentPage({required this.student})
      : _firstNameController =
            TextEditingController(text: student['firstName']),
        _lastNameController = TextEditingController(text: student['lastName']),
        _emailController = TextEditingController(text: student['email']),
        _namewithinitialController =
            TextEditingController(text: student['name with initial']);

  // Function to update the student data
  Future<void> _updateStudent() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(student['id'])
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'name with initial': _namewithinitialController.text,
      });
      // After updating, go back to the previous page
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _namewithinitialController,
              decoration: InputDecoration(labelText: 'name with initial'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateStudent,
              child: Text('Update Student'),
            ),
          ],
        ),
      ),
    );
  }
}*/
