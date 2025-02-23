class Attendance {
  String? id; // Firestore document ID
  String? teacherName;
  String? date; // Date in 'yyyy-MM-dd' format
  String? startTime; // Start time in a string format, e.g., '9:00 AM'
  String? endTime;
  String? batch; // End time in a string format, e.g., '9:15 AM'
  Map<String, bool>?
      attendanceStatus; // Map of student IDs to their attendance status

  // Constructor
  Attendance({
    this.id,
    this.teacherName,
    this.date,
    this.startTime,
    this.endTime,
    this.attendanceStatus,
    this.batch,
  });

  // Factory constructor to create an Attendance object from Firestore data
  factory Attendance.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Attendance(
      id: documentId,
      teacherName: data['teacherName'] as String?,
      date: data['date'] as String?,
      startTime: data['startTime'] as String?,
      endTime: data['endTime'] as String?,
      batch: data['batch'] as String?,
      attendanceStatus: data['attendanceStatus'] != null
          ? Map<String, bool>.from(data['attendanceStatus'])
          : null,
    );
  }

  // Method to convert an Attendance object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'teacherName': teacherName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'attendanceStatus': attendanceStatus,
      'batch': batch,
    };
  }
}
