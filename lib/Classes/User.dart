class Customuser {
  String? id; // Firestore document ID
  String? email;
  String? firstName;
  String? lastName;
  String? nameWithInitial;
  String? role;
  String? stream;
  String? subject; // Now a single value
  String? childName;
  String? batch;

  // Constructor
  Customuser({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.nameWithInitial,
    this.role,
    this.stream,
    this.subject,
    this.childName,
    this.batch,
  });

  // Factory constructor to create a User object from Firestore data
  factory Customuser.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Customuser(
      id: documentId,
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      nameWithInitial: data['name with initial'] as String?,
      role: data['role'] as String?,
      stream: data['stream'] as String?,
      subject: data['subject'] as String?, // Adjusted for single value
      childName: data['childName'] as String?,
      batch: data['batch'] as String?,
    );
  }

  // Method to convert a User object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'name with initial': nameWithInitial,
      'role': role,
      'stream': stream,
      'subject': subject, // Adjusted for single value
      'childName': childName,
      'batch': batch,
    };
  }
}
