// lib/models/attendance_record.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  String id;
  String studentId; // Reference to the student's document ID
  String studentName;
  String studentUniqueId; // The unique ID of the student (e.g., admission number)
  String status; // 'Present' or 'Absent'
  DateTime timestamp; // Full timestamp of attendance
  String date; // Formatted date string (e.g., "MM/DD/YYYY")
  String time; // Formatted time string (e.g., "HH:MM:SS AM/PM")

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentUniqueId,
    required this.status,
    required this.timestamp,
    required this.date,
    required this.time,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentUniqueId: data['studentUniqueId'] ?? '',
      status: data['status'] ?? 'Absent',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      date: data['date'] ?? '',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentUniqueId': studentUniqueId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'date': date,
      'time': time,
    };
  }
}