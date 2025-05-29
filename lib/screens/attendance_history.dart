// lib/screens/attendance_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biometric_attendance_app/services/app_state.dart';
import 'package:biometric_attendance_app/models/attendance_record.dart';
import 'package:intl/intl.dart';

class AttendanceHistory extends StatefulWidget {
  @override
  _AttendanceHistoryState createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  DateTime? _selectedFilterDate;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Filter records by date
    final filteredRecords = appState.attendanceRecords.where((record) {
      if (_selectedFilterDate == null) return true; // No filter applied
      final filterDateFormatted = DateFormat('MM/dd/yyyy').format(_selectedFilterDate!);
      return record.date == filterDateFormatted;
    }).toList();

    // Group records by date
    Map<String, List<AttendanceRecord>> groupedRecords = {};
    for (var record in filteredRecords) {
      groupedRecords.putIfAbsent(record.date, () => []).add(record);
    }

    // Sort dates (latest first)
    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => DateFormat('MM/dd/yyyy').parse(b).compareTo(DateFormat('MM/dd/yyyy').parse(a)));


    if (appState.attendanceRecords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No attendance records found yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedFilterDate == null
                  ? 'Select Date to Filter'
                  : 'Filter: ${DateFormat('MM/dd/yyyy').format(_selectedFilterDate!)}',
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedFilterDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != _selectedFilterDate) {
                setState(() {
                  _selectedFilterDate = picked;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        if (sortedDates.isEmpty && _selectedFilterDate != null)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No records found for the selected date.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final recordsForDate = groupedRecords[date]!;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $date',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const Divider(height: 20, thickness: 1),
                      SingleChildScrollView( // For horizontal scrolling if many columns
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 60,
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.indigo.withOpacity(0.1)),
                          columns: const [
                            DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: recordsForDate.map((record) {
                            return DataRow(cells: [
                              DataCell(Text(record.studentName)),
                              DataCell(Text(record.studentUniqueId)),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: record.status == 'Present' ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  record.status,
                                  style: TextStyle(
                                    color: record.status == 'Present' ? Colors.green[700] : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                              DataCell(Text(record.time)),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}