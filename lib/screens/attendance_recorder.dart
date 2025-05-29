// lib/screens/attendance_recorder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biometric_attendance_app/services/app_state.dart';
import 'package:biometric_attendance_app/models/student.dart';

class AttendanceRecorder extends StatefulWidget {
  @override
  _AttendanceRecorderState createState() => _AttendanceRecorderState();
}

class _AttendanceRecorderState extends State<AttendanceRecorder> {
  Map<String, bool> _selectedStudents = {}; // {studentId: isPresent}
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context);
    // Initialize _selectedStudents when students data changes or for the first time
    if (_selectedStudents.isEmpty || _selectedStudents.length != appState.students.length) {
      _selectedStudents = {for (var student in appState.students) student.id: false};
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.students.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No students available to record attendance. Please add students first.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: appState.students.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final student = appState.students[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${student.name} (${student.studentId})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Switch(
                        value: _selectedStudents[student.id] ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _selectedStudents[student.id] = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red[200],
                      ),
                      Text(
                        (_selectedStudents[student.id] ?? false) ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: (_selectedStudents[student.id] ?? false) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await appState.recordAttendance(_selectedStudents);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attendance recorded successfully!')),
                      );
                      // Optionally reset switches after recording
                      setState(() {
                        _selectedStudents = {for (var student in appState.students) student.id: false};
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error recording attendance: ${e.toString()}')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
        ),
      ],
    );
  }
}