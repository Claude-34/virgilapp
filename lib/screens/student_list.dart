import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../services/app_state.dart';

class StudentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.students.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No students added yet. Go to "Add Student" tab to add new students.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: appState.students.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final student = appState.students[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Text(
                  student.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Student ID: ${student.studentId}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete ${student.name}?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    try {
                      await appState.deleteStudent(student.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${student.name} deleted successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting student: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}