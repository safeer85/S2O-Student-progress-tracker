import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Screens/AddTeacherPage.dart';
import 'package:s20/Screens/ParentManagePage.dart';
import 'package:s20/Screens/StudentManage.dart';
import 'package:s20/components/Drawer.dart';
import 'ChatPage.dart';

class PrincipalDashboard extends StatefulWidget {
  final Customuser user;

  const PrincipalDashboard({required this.user});

  @override
  _PrincipalDashboardState createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // For demo purposes only. Use Firebase Auth in production.
  final TextEditingController _nameWithInitialController =
      TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Variables to store the user counts
  int totalUsers = 0;
  int teachersCount = 0;
  int studentsCount = 0;
  int parentsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserCounts();
  }

  Future<void> _fetchUserCounts() async {
    totalUsers = await _countUsersByRole(
        'any'); // Replace 'any' with all roles if needed
    teachersCount = await _countUsersByRole('Teacher');
    studentsCount = await _countUsersByRole('Student');
    parentsCount = await _countUsersByRole('Parent');
    totalUsers = teachersCount + studentsCount + parentsCount;

    setState(() {}); // Update the UI after fetching the counts
  }

  // Method to get the count of users with a specific role
  Future<int> _countUsersByRole(String role) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.length; // Returns the number of documents found
  }

  Future<void> _addTeacher() async {
    if (_emailController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameWithInitialController.text.isNotEmpty &&
        _subjectController.text.isNotEmpty) {
      await _firestore.collection('users').add({
        'email': _emailController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'role': 'Teacher',
        'password': _passwordController.text,
        'name with initial': _nameWithInitialController.text,
        'subject': _subjectController.text,
      });

      // Clear input fields
      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _passwordController.clear();
      _nameWithInitialController.clear();
      _subjectController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teacher added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  Stream<List<Customuser>> _getTeachers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customuser.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  String _generateChatId(String? userId1, String? userId2) {
    final sortedIds = [userId1!, userId2!]..sort();
    return sortedIds.join('_');
  }

// Method to get the count of users with a specific role
  Future<int> _getUserCountByRole(String role) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.length; // Returns the number of documents found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Principal Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.user.nameWithInitial}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display the counts of users, teachers, students, and parents
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildUserCountCard('Total Users', totalUsers),
                _buildUserCountCard('Teachers', teachersCount),
                _buildUserCountCard('Students', studentsCount),
                _buildUserCountCard('Parents', parentsCount),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.school,
                    title: 'Manage Students',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentManagePage(), // Navigate to Student Manage Page
                      ),
                    ),
                  ),

                  // Card for managing parents
                  _buildFeatureCard(
                    context,
                    icon: Icons.family_restroom,
                    title: 'Manage Parents',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ParentManagePage(), // Navigate to Parent Manage Page
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.person_add,
                    title: 'Add Teacher',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        /*builder: (context) => AddTeacherPage(
                          addTeacherFunction: _addTeacher,
                          emailController: _emailController,
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          passwordController: _passwordController,
                          nameWithInitialController: _nameWithInitialController,
                          subjectController: _subjectController,
                        )*/
                        builder: (context) => AddTeacherPage(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.chat,
                    title: 'Chat with Teachers',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherListPage(
                          getTeachersStream: _getTeachers,
                          currentUser: widget.user,
                          generateChatId: _generateChatId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.teal),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper method to build the user count cards
Widget _buildUserCountCard(String title, int count) {
  return Card(
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('$count',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

// Add Teacher Page
/*class AddTeacherPage extends StatelessWidget {
  final Function addTeacherFunction;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passwordController;
  final TextEditingController nameWithInitialController;
  final TextEditingController subjectController;

  const AddTeacherPage({
    required this.addTeacherFunction,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.passwordController,
    required this.nameWithInitialController,
    required this.subjectController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Add Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Teacher Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: firstNameController,
                    labelText: 'First Name',
                    keyboardType: TextInputType.name,
                  ),
                  _buildTextField(
                    controller: lastNameController,
                    labelText: 'Last Name',
                    keyboardType: TextInputType.name,
                  ),
                  _buildTextField(
                    controller: nameWithInitialController,
                    labelText: 'Name with initial',
                    keyboardType: TextInputType.name,
                  ),
                  _buildTextField(
                    controller: subjectController,
                    labelText: 'Subject',
                    keyboardType: TextInputType.name,
                  ),
                  _buildTextField(
                    controller: emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => addTeacherFunction(),
                      child: Text('Add Teacher'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade500),
          ),
          filled: true,
          fillColor: Colors.teal.shade50,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}*/

// Teacher List Page
class TeacherListPage extends StatelessWidget {
  final Stream<List<Customuser>> Function() getTeachersStream;
  final Customuser currentUser;
  final String Function(String?, String?) generateChatId;

  const TeacherListPage({
    required this.getTeachersStream,
    required this.currentUser,
    required this.generateChatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Teachers'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: StreamBuilder<List<Customuser>>(
        stream: getTeachersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                strokeWidth: 2,
              ),
            );
          }

          final teachers = snapshot.data;

          if (teachers == null || teachers.isEmpty) {
            return Center(
              child: Text(
                'No teachers available.',
                style: TextStyle(fontSize: 18, color: Colors.teal.shade700),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          user: currentUser,
                          chatId: generateChatId(currentUser.id, teacher.id),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${teacher.firstName} ${teacher.lastName}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                teacher.email ?? 'No email provided',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.message,
                          color: Colors.teal,
                          size: 30,
                        ),
                      ],
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
