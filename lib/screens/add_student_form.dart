import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virgilapp/services/app_state.dart';
import 'add_student_form.dart'; // If you're importing it from another fil

class AddStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Student"),
      ),
      body: AddStudentForm(), // This is the form widget
    );
  }
}

class AddStudentForm extends StatefulWidget {
  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  String? _message;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add New Student',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Student Name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _studentIdController,
            decoration: InputDecoration(
              labelText: 'Student ID (Unique)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _studentIdController.text.isEmpty) {
                      setState(() => _message = 'Please fill all fields.');
                      return;
                    }
                    setState(() {
                      _isLoading = true;
                      _message = null;
                    });
                    try {
                      await appState.addStudent(
                        _nameController.text,
                        _studentIdController.text,
                      );
                      setState(() {
                        _message = 'Student added successfully!';
                        _nameController.clear();
                        _studentIdController.clear();
                      });
                    } catch (e) {
                      setState(() =>
                          _message = 'Error: ${e.toString().split(':').last}');
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Add Student'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _message!,
                style: TextStyle(
                  color:
                      _message!.startsWith('Error') ? Colors.red : Colors.green,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
