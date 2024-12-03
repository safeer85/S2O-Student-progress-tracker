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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  // Fetch marks for the teacher's subject
  Future<void> _fetchMarks() async {
    try {
      final snapshot = await _firestore
          .collection('examMarks')
          .where('teacherSubject', isEqualTo: widget.user.subject)
          .get();

      final marks = snapshot.docs.map((doc) {
        return ExamMarks.fromFirestore(doc.data(), doc.id);
      }).toList();

      setState(() {
        _examMarks = marks;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching marks: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a mark entry
  Future<void> _deleteMark(String id) async {
    try {
      await _firestore.collection('examMarks').doc(id).delete();
      setState(() {
        _examMarks.removeWhere((mark) => mark.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marks deleted successfully!')),
      );
    } catch (error) {
      print('Error deleting marks: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete marks. Please try again.')),
      );
    }
  }

  // Edit marks
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
          SnackBar(content: Text('Marks updated successfully!')),
        );
      } catch (error) {
        print('Error updating marks: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update marks. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marks for ${widget.user.subject}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _examMarks.isEmpty
              ? Center(child: Text('No marks available.'))
              : ListView.builder(
                  itemCount: _examMarks.length,
                  itemBuilder: (context, index) {
                    final mark = _examMarks[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                            'Student ID: ${mark.studentId}\nExam Type: ${mark.examType}\nDate: ${mark.examDate}'),
                        subtitle: Text(
                          'Marks: ${mark.marks?.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editMark(mark),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
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
