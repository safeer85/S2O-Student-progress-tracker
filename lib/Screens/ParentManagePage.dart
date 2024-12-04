import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ParentManagePage extends StatelessWidget {
  // Fetch parents from Firestore where role is 'Parent'
  Stream<List<Map<String, dynamic>>> _getParents() {
    return FirebaseFirestore.instance
        .collection('users') // Reference to the users collection
        .where('role', isEqualTo: 'Parent') // Filter by role 'Parent'
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'firstName': doc['firstName'],
                  'lastName': doc['lastName'],
                  'email': doc['email'],
                  'childName': doc['childName'],
                  'name with initial':
                      doc['name with initial'], // Specific field
                })
            .toList());
  }

  // Function to delete a parent
  void _deleteParent(BuildContext context, String parentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parent deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting parent: $e')),
      );
    }
  }

  // Function to navigate to the edit page
  void _editParent(BuildContext context, Map<String, dynamic> parent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditParentPage(parent: parent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Management'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getParents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No parents found'));
          }

          final parents = snapshot.data!;

          return ListView.builder(
            itemCount: parents.length,
            itemBuilder: (context, index) {
              final parent = parents[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    '${parent['firstName']} ${parent['lastName']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Email: ${parent['email']}'),
                      Text('Child: ${parent['childName']}'),
                      Text('Initials: ${parent['name with initial']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editParent(context, parent),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteParent(context, parent['id']),
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

class EditParentPage extends StatelessWidget {
  final Map<String, dynamic> parent;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _childNameController;
  final TextEditingController _namewithinitialController;

  EditParentPage({required this.parent})
      : _firstNameController = TextEditingController(text: parent['firstName']),
        _lastNameController = TextEditingController(text: parent['lastName']),
        _emailController = TextEditingController(text: parent['email']),
        _childNameController = TextEditingController(text: parent['childName']),
        _namewithinitialController =
            TextEditingController(text: parent['name with initial']);

  // Function to update parent data
  Future<void> _updateParent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parent['id'])
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'childName': _childNameController.text,
        'name with initial': _namewithinitialController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parent updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating parent: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Parent'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _namewithinitialController,
                decoration: InputDecoration(
                  labelText: 'Name with Initial',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _childNameController,
                decoration: InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateParent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Update Parent',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ParentManagePage extends StatelessWidget {
  // Fetch parents from Firestore where role is 'Parent'
  Stream<List<Map<String, dynamic>>> _getParents() {
    return FirebaseFirestore.instance
        .collection('users') // Reference to the users collection
        .where('role', isEqualTo: 'Parent') // Filter by role 'Parent'
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'firstName': doc['firstName'],
                  'lastName': doc['lastName'],
                  'email': doc['email'],
                  'childName': doc['childName'],
                  'name with initial':
                      doc['name with initial'], // Parent-specific field
                })
            .toList());
  }

  // Function to delete a parent
  void _deleteParent(BuildContext context, String parentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parent deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting parent')),
      );
    }
  }

  // Function to navigate to the edit page
  void _editParent(BuildContext context, Map<String, dynamic> parent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditParentPage(parent: parent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Management'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getParents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No parents found'));
          }

          final parents = snapshot.data!;

          return ListView.builder(
            itemCount: parents.length,
            itemBuilder: (context, index) {
              final parent = parents[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${parent['firstName']} ${parent['lastName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${parent['email']}'),
                      Text(
                          'Child: ${parent['childName']}'), // Display child name
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editParent(context, parent),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteParent(context, parent['id']),
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

class EditParentPage extends StatelessWidget {
  final Map<String, dynamic> parent;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _childNameController;
  final TextEditingController _namewithinitialController;

  EditParentPage({required this.parent})
      : _firstNameController = TextEditingController(text: parent['firstName']),
        _lastNameController = TextEditingController(text: parent['lastName']),
        _emailController = TextEditingController(text: parent['email']),
        _childNameController = TextEditingController(text: parent['childName']),
        _namewithinitialController =
            TextEditingController(text: parent['name with initial']);

  // Function to update parent data
  Future<void> _updateParent() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parent['id'])
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'childName': _childNameController.text,
        'name with initial': _namewithinitialController.text,
      });
    } catch (e) {
      print('Error updating parent: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Parent'),
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
              controller: _namewithinitialController,
              decoration: InputDecoration(labelText: 'name with initial'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _childNameController,
              decoration: InputDecoration(labelText: 'Child Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateParent,
              child: Text('Update Parent'),
            ),
          ],
        ),
      ),
    );
  }
}*/
