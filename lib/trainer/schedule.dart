import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DailyWorkoutPlanPage extends StatefulWidget {
  final String userId;
  final String userName;

  DailyWorkoutPlanPage({required this.userId, required this.userName});

  @override
  _DailyWorkoutPlanPageState createState() => _DailyWorkoutPlanPageState();
}

class _DailyWorkoutPlanPageState extends State<DailyWorkoutPlanPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 7, minute: 0);

  List<Map<String, dynamic>> _workouts = [];

  void _addExerciseField() {
    setState(() {
      _workouts.add({
        'exercise': '',
        'type': '',
        'sets': '',
        'reps': '',
      });
    });
  }

  Future<void> _submitPlan() async {
    final trainerId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('UserPlans').add({
        'userId': widget.userId,
        'trainerId': trainerId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'scheduledTime': _selectedTime.format(context),
        'workouts': _workouts.map((w) => {
          'exercise': w['exercise'],
          'type': w['type'],
          'sets': int.tryParse(w['sets']) ?? 0,
          'reps': int.tryParse(w['reps']) ?? 0,
        }).toList(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Plan saved for ${widget.userName}")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _buildExerciseInput(int index) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Exercise Name'),
          onChanged: (val) => _workouts[index]['exercise'] = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Type (e.g., Cardio, Strength)'),
          onChanged: (val) => _workouts[index]['type'] = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Sets'),
          keyboardType: TextInputType.number,
          onChanged: (val) => _workouts[index]['sets'] = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Reps'),
          keyboardType: TextInputType.number,
          onChanged: (val) => _workouts[index]['reps'] = val,
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Daily Plan for ${widget.userName}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Row(
            children: [
              Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
              Spacer(),
              TextButton(onPressed: _pickDate, child: Text("Pick Date"))
            ],
          ),
          Row(
            children: [
              Text("Time: ${_selectedTime.format(context)}"),
              Spacer(),
              TextButton(onPressed: _pickTime, child: Text("Pick Time"))
            ],
          ),
          SizedBox(height: 20),
          ..._workouts.asMap().entries.map((e) => _buildExerciseInput(e.key)).toList(),
          ElevatedButton(onPressed: _addExerciseField, child: Text("Add Exercise")),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _submitPlan, child: Text("Submit Plan")),
        ]),
      ),
    );
  }
}
