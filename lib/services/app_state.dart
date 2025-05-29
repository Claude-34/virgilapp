// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biometric_attendance_app/models/student.dart';
import 'package:biometric_attendance_app/models/attendance_record.dart';
import 'package:intl/intl.dart'; // For date/time formatting

class AppState with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  String? get userId => _currentUser?.uid;
  bool _authReady = false;
  bool get authReady => _authReady;

  List<Student> _students = [];
  List<Student> get students => _students;

  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // Constructor: Initialize listeners when AppState is created
  AppState() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        print("User signed in: ${user.uid}");
        // Listen to student and attendance data only when a user is signed in
        _listenToStudents();
        _listenToAttendanceRecords();
      } else {
        print("User signed out.");
        // Try to sign in anonymously if no user is present
        try {
          await _auth.signInAnonymously();
        } catch (e) {
          print("Error signing in anonymously: $e");
        }
        _students = [];
        _attendanceRecords = [];
      }
      _authReady = true; // Mark auth as ready after initial check
      notifyListeners(); // Notify UI that auth state has changed
    });
  }

  // Firestore data listeners
  void _listenToStudents() {
    if (userId != null) {
      _db
          .collection('artifacts')
          .doc('default-app-id') // Use your actual app ID from Firebase Console or firebase_options.dart
          .collection('users')
          .doc(userId)
          .collection('students')
          .snapshots()
          .listen((snapshot) {
        _students = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
        notifyListeners();
      }, onError: (error) => print("Error getting students: $error"));
    }
  }

  void _listenToAttendanceRecords() {
    if (userId != null) {
      _db
          .collection('artifacts')
          .doc('default-app-id') // Use your actual app ID
          .collection('users')
          .doc(userId)
          .collection('attendanceRecords')
          .snapshots()
          .listen((snapshot) {
        _attendanceRecords = snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
        // Sort by timestamp descending (latest first)
        _attendanceRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }, onError: (error) => print("Error getting attendance records: $error"));
    }
  }

  // --- Firebase Operations ---

  Future<void> addStudent(String name, String studentId) async {
    if (userId == null) throw Exception('User not authenticated.');

    // Check for duplicate student ID
    final querySnapshot = await _db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('students')
        .where('studentId', isEqualTo: studentId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('Student with this ID already exists.');
    }

    await _db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('students')
        .add({
      'name': name,
      'studentId': studentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Data will automatically update via the listener
  }

  Future<void> deleteStudent(String studentDocId) async {
    if (userId == null) throw Exception('User not authenticated.');
    await _db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('students')
        .doc(studentDocId)
        .delete();
    // Data will automatically update via the listener
  }

  Future<void> recordAttendance(Map<String, bool> selectedStudents) async {
    if (userId == null) throw Exception('User not authenticated.');

    WriteBatch batch = _db.batch();
    final attendanceCollectionRef = _db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('attendanceRecords');

    final now = DateTime.now();
    final dateFormat = DateFormat('MM/dd/yyyy');
    final timeFormat = DateFormat('hh:mm:ss a');

    for (var student in _students) { // Iterate over all known students
      final isPresent = selectedStudents[student.id] ?? false;
      final record = AttendanceRecord(
        id: '', // Firestore will generate
        studentId: student.id,
        studentName: student.name,
        studentUniqueId: student.studentId,
        status: isPresent ? 'Present' : 'Absent',
        timestamp: now,
        date: dateFormat.format(now),
        time: timeFormat.format(now),
      );
      batch.set(attendanceCollectionRef.doc(), record.toFirestore());
    }
    await batch.commit();
    // Data will automatically update via the listener
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _students = [];
    _attendanceRecords = [];
    notifyListeners();
  }
}