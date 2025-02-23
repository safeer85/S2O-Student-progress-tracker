import 'package:firebase_auth/firebase_auth.dart';
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

  Map<String, Map<String, List<ExamMarks>>> _batchAndTypeWiseMarks = {};
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

      final batchAndTypeWiseMarks = <String, Map<String, List<ExamMarks>>>{};
      for (var mark in marks) {
        final batch = mark.batch ?? 'Unknown Batch';
        final examType = mark.examType ?? 'Unknown Exam Type';

        batchAndTypeWiseMarks[batch] ??= {};
        batchAndTypeWiseMarks[batch]![examType] ??= [];
        batchAndTypeWiseMarks[batch]![examType]!.add(mark);
      }

      setState(() {
        _batchAndTypeWiseMarks = batchAndTypeWiseMarks;
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
          final name = '${data?['name with initial']}';
          studentNames[studentId] = name;
        }
      }
    } catch (error) {
      print('Error fetching student names: $error');
    }
    return studentNames;
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
        title: Text('Marks for ${widget.user.subject}'),
        backgroundColor: const Color.fromARGB(255, 44, 100, 183),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _batchAndTypeWiseMarks.isEmpty
              ? const Center(
                  child: Text(
                    'No marks available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _batchAndTypeWiseMarks.keys.length,
                  itemBuilder: (context, batchIndex) {
                    final batch =
                        _batchAndTypeWiseMarks.keys.elementAt(batchIndex);
                    final examTypes = _batchAndTypeWiseMarks[batch]!;

                    return ExpansionTile(
                      title: Text(
                        'Batch: $batch',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: examTypes.entries.map((entry) {
                        final examType = entry.key;
                        final marks = entry.value;

                        return ExpansionTile(
                          title: Text(
                            'Exam Type: $examType',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: marks.map((mark) {
                            final studentName =
                                _studentNames[mark.studentId] ?? 'Unknown';
                            return ListTile(
                              title: Text(
                                'Student: $studentName\nDate: ${mark.examDate}',
                              ),
                              subtitle: Text(
                                'Marks: ${mark.marks?.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _editMark(mark, batch, examType),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteMark(mark.id!, batch, examType),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }

  Future<void> _editMark(ExamMarks mark, String batch, String examType) async {
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
          final index = _batchAndTypeWiseMarks[batch]![examType]
              ?.indexWhere((m) => m.id == mark.id);
          if (index != null && index != -1) {
            _batchAndTypeWiseMarks[batch]![examType]?[index].marks =
                updatedMarks;
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

  Future<void> _deleteMark(String id, String batch, String examType) async {
    bool? confirmDelete = await _showDeleteConfirmation();
    if (confirmDelete == true) {
      try {
        await _firestore.collection('examMarks').doc(id).delete();
        setState(() {
          _batchAndTypeWiseMarks[batch]![examType]
              ?.removeWhere((mark) => mark.id == id);
          if (_batchAndTypeWiseMarks[batch]![examType]?.isEmpty ?? false) {
            _batchAndTypeWiseMarks[batch]!.remove(examType);
          }
          if (_batchAndTypeWiseMarks[batch]?.isEmpty ?? false) {
            _batchAndTypeWiseMarks.remove(batch);
          }
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
}
