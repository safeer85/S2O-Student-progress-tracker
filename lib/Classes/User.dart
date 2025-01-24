import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Customuser {
  String? id; // Firestore document ID
  String? email;
  String? firstName;
  String? lastName;
  String? nameWithInitial;
  String? role;
  String? stream;
  String? subject;
  String? childName;
  String? batch;
  bool? isOnline; // New field for online status

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
    this.isOnline,
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
      subject: data['subject'] as String?,
      childName: data['childName'] as String?,
      batch: data['batch'] as String?,
      isOnline: data['isOnline'] as bool?,
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
      'subject': subject,
      'childName': childName,
      'batch': batch,
      'isOnline': isOnline,
    };
  }
}