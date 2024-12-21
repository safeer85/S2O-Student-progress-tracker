import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:s20/Classes/User.dart'; // Import your Customuser class
import 'package:s20/Classes/Attendance.dart';
import 'package:s20/main.dart'; // Import your Attendance class

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Map<String, bool> attendanceStatus = {};
  List<Customuser> students = []; // List to store students
  String teacherName = "Unknown"; // Placeholder for the teacher's name
  bool isLoading = true;
  bool isWithinTimeWindow = true;
  String? sessionId; // Unique identifier for each attendance session

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
    _fetchStudents();
  }

  // Fetch the teacher's name from Firestore
  Future<void> _fetchTeacherName() async {
    try {
      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot teacherSnapshot =
          await _firestore.collection('users').doc(currentUserUid).get();

      setState(() {
        teacherName = teacherSnapshot['name with initial'] ?? 'Unknown';
      });
    } catch (error) {
      print("Error fetching teacher name: $error");
    }
  }

  // Fetch the list of students from Firestore
  Future<void> _fetchStudents() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      setState(() {
        students = snapshot.docs.map((doc) {
          return Customuser.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Initialize attendance status for each student
        for (var student in students) {
          attendanceStatus[student.id!] = false;
        }
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching students: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Date picker to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time picker for start time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  // Time picker for end time
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  // Save the attendance session
  Future<void> _saveAttendance() async {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select date, start time, and end time")));
      return;
    }

    DateTime now = DateTime.now();
    DateTime endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (now.isAfter(endDateTime)) {
      setState(() {
        isWithinTimeWindow = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cannot edit attendance after end time")));
      return;
    }

    sessionId =
        "${selectedDate!.toIso8601String()}_${startTime!.format(context)}_${teacherName}";

    try {
      // Save attendance data
      Attendance attendance = Attendance(
        teacherName: teacherName,
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
        startTime: startTime!.format(context),
        endTime: endTime!.format(context),
        attendanceStatus: attendanceStatus,
      );

      await _firestore
          .collection('attendance_sessions')
          .doc(sessionId)
          .set(attendance.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance saved successfully")));
    } catch (error) {
      print("Error saving attendance: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance"),
        backgroundColor: Colors.teal, // Enhanced color scheme
        centerTitle: true, // Centered title for a cleaner look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced date and time pickers
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text("Date"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectStartTime(context),
                  child: const Text("Start Time"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectEndTime(context),
                  child: const Text("End Time"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Display selected date and times
            if (selectedDate != null)
              Text(
                  "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"),
            if (startTime != null)
              Text("Start Time: ${startTime!.format(context)}"),
            if (endTime != null) Text("End Time: ${endTime!.format(context)}"),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(student.nameWithInitial ?? "Unknown"),
                            trailing: Checkbox(
                              value: attendanceStatus[student.id],
                              onChanged: isWithinTimeWindow
                                  ? (bool? newValue) {
                                      setState(() {
                                        attendanceStatus[student.id!] =
                                            newValue!;
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAttendance,
              child: const Text("Save Attendance"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width button
                backgroundColor: Colors.teal, // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
