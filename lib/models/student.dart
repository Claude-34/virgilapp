// lib/models/student.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String id;
  String name;
  String studentId; // Unique ID for the student
  DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.createdAt,
  });

  // Factory constructor to create a Student from a Firestore DocumentSnapshot
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert a Student object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'studentId': studentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}