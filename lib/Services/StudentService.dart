import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Fetch students with the role "Student"
  Future<List<Map<String, dynamic>>> fetchStudents() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .get();

    // Convert documents to a list of maps
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
