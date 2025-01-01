import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s20/Classes/Marks.dart';
import 'package:s20/Classes/User.dart';
import 'package:s20/Services/EditStudentMarks.dart';

class ViewMarksPage extends StatefulWidget {
  final Customuser user;

  ViewMarksPage({required this.user});

  @override
  _ViewMarksPageState createState() => _ViewMarksPageState();
}

class _ViewMarksPageState extends State<ViewMarksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ExamMarks> _examMarks = [];
  Map<String, String> _studentNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  Future<void> _fetchMarks() async {
    try {
      final snapshot = await _firestore
          .collection('examMarks')
          .where('teacherSubject', isEqualTo: widget.user.subject)
          .get();

      final marks = snapshot.docs.map((doc) {
        return ExamMarks.fromFirestore(doc.data(), doc.id);
      }).toList();

      final studentIds =
          marks.map((mark) => mark.studentId).whereType<String>().toSet();
      final studentNames = await _fetchStudentNames(studentIds);

      setState(() {
        _examMarks = marks;
        _studentNames = studentNames;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching marks: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _fetchStudentNames(Set<String> studentIds) async {
    final studentNames = <String, String>{};
    try {
      for (final studentId in studentIds) {
        final doc = await _firestore.collection('users').doc(studentId).get();
        if (doc.exists) {
          final data = doc.data();
          final name = '${data?['name with initial']} ';
          studentNames[studentId] = name;
        }
      }
    } catch (error) {
      print('Error fetching student names: $error');
    }
    return studentNames;
  }

  Future<void> _deleteMark(String id) async {
    bool? confirmDelete = await _showDeleteConfirmation();
    if (confirmDelete == true) {
      try {
        await _firestore.collection('examMarks').doc(id).delete();
        setState(() {
          _examMarks.removeWhere((mark) => mark.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks deleted successfully!')),
        );
      } catch (error) {
        print('Error deleting marks: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete marks. Please try again.')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete these marks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMark(ExamMarks mark) async {
    final updatedMarks = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditMarksDialog(mark: mark),
    );

    if (updatedMarks != null) {
      try {
        await _firestore.collection('examMarks').doc(mark.id).update({
          'marks': updatedMarks,
        });

        setState(() {
          final index = _examMarks.indexWhere((m) => m.id == mark.id);
          if (index != -1) {
            _examMarks[index].marks = updatedMarks;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks updated successfully!')),
        );
      } catch (error) {
        print('Error updating marks: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update marks. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marks for ${widget.user.subject}'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _examMarks.isEmpty
              ? const Center(
                  child: Text('No marks available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  itemCount: _examMarks.length,
                  itemBuilder: (context, index) {
                    final mark = _examMarks[index];
                    final studentName =
                        _studentNames[mark.studentId] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          'Student: $studentName\nExam Type: ${mark.examType}\nDate: ${mark.examDate}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Marks: ${mark.marks?.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editMark(mark),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMark(mark.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
