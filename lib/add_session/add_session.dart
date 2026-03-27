import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:start2/models/pen.dart';

class AddSessionScreen extends StatefulWidget {
  final int penIndex;

  const AddSessionScreen({super.key, required this.penIndex});

  @override
  _AddSessionScreenState createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  DateTime? _selectedDate;
  late Box<Pen> _penBox;
  late Pen _pen;

  @override
  void initState() {
    super.initState();
    _penBox = Hive.box<Pen>('pens');
    _pen = _penBox.getAt(widget.penIndex)!;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && !_pen.sessions.contains(picked)) {
      setState(() {
        _selectedDate = picked;
      });
    } else if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date already added.')),
      );
    }
  }

  void _confirmDate() {
    if (_selectedDate != null && !_pen.sessions.contains(_selectedDate)) {
      setState(() {
        // Only add session if the date is not already added
        _pen.sessions.add(_selectedDate!);
        _pen.save(); // Save only after modification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Session added: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}')),
        );
        _selectedDate = null; // Reset selected date after confirming
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _selectedDate == null
                  ? 'No date selected!'
                  : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmDate,
              child: const Text('Confirm Date'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _pen.sessions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Session: ${DateFormat('yyyy-MM-dd').format(_pen.sessions[index])}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
