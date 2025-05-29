// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biometric_attendance_app/services/app_state.dart';
import 'package:biometric_attendance_app/screens/add_student_form.dart';
import 'package:biometric_attendance_app/screens/student_list.dart';
import 'package:biometric_attendance_app/screens/attendance_recorder.dart';
import 'package:biometric_attendance_app/screens/attendance_history.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        actions: [
          // Display current user ID (for debugging/info)
          if (appState.userId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  'ID: ${appState.userId!.substring(0, 6)}...', // Show first few chars
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await appState.logout();
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // If many tabs
          tabs: const [
            Tab(text: 'Add Student', icon: Icon(Icons.person_add)),
            Tab(text: 'View Students', icon: Icon(Icons.people)),
            Tab(text: 'Record Attendance', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Attendance History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddStudentForm(),
          StudentList(),
          AttendanceRecorder(),
          AttendanceHistory(),
        ],
      ),
    );
  }
  
  AddStudentForm() {}
  
  StudentList() {}
  
  AttendanceRecorder() {}
  
  AttendanceHistory() {}
}