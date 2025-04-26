import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final List<Map<String, dynamic>> _activities = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _addActivity(String title, String description, String sleepHours, String weight, String workout) async {
    final newActivity = {
      'title': title,
      'description': description,
      'sleepHours': sleepHours,
      'weight': weight,
      'workout': workout,
      'date': DateFormat('MMM d, y • hh:mm a').format(DateTime.now()),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final docRef = await _firestore
            .collection('Diary')
            .doc(uid)
            .collection('Entries')
            .add(newActivity);

        setState(() {
          _activities.insert(0, {
            'id': docRef.id, // 🔥 Save the Firestore document ID
            ...newActivity,
          });
          _listKey.currentState?.insertItem(0);
        });
      }
    } catch (e) {
      print("Error adding activity to Firebase: $e");
    }

    Navigator.pop(context);
  }

  void _loadActivities() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final snapshot = await _firestore
          .collection('Diary')
          .doc(uid)
          .collection('Entries')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _activities.clear();
        _activities.addAll(snapshot.docs.map((doc) => {
              'id': doc.id, // 🔥 Save Firestore doc ID
              ...doc.data(),
            }).toList());
      });
    }
  }

  void _deleteActivity(int index) async {
    final removedActivity = _activities[index];
    final uid = _auth.currentUser?.uid;

    setState(() {
      _activities.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildActivityCard(removedActivity, animation, index),
        duration: const Duration(milliseconds: 300),
      );
    });

    try {
      if (uid != null) {
        final docId = removedActivity['id'];
        await _firestore
            .collection('Diary')
            .doc(uid)
            .collection('Entries')
            .doc(docId)
            .delete();
      }
    } catch (e) {
      print("Error deleting activity from Firebase: $e");
    }
  }

  void _showAddActivityDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController sleepController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController workoutController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Add New Activity", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(controller: titleController, label: "Activity Title"),
                const SizedBox(height: 10),
                _buildInputField(controller: descriptionController, label: "Description"),
                const SizedBox(height: 10),
                _buildIncrementField(controller: sleepController, label: "Sleep Hours", allowDecimal: true),
                const SizedBox(height: 10),
                _buildIncrementField(controller: weightController, label: "Weight (kg)", allowDecimal: true),
                const SizedBox(height: 10),
                _buildInputField(controller: workoutController, label: "Workout Details"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    sleepController.text.isNotEmpty &&
                    weightController.text.isNotEmpty &&
                    workoutController.text.isNotEmpty) {
                  _addActivity(
                    titleController.text,
                    descriptionController.text,
                    sleepController.text,
                    weightController.text,
                    workoutController.text,
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildIncrementField({required TextEditingController controller, required String label, bool allowDecimal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              InkWell(
                onTap: () {
                  double current = double.tryParse(controller.text) ?? 0;
                  setState(() {
                    controller.text = (current + 0.1).toStringAsFixed(1);
                  });
                },
                child: const Icon(Icons.arrow_drop_up, color: Colors.white),
              ),
              InkWell(
                onTap: () {
                  double current = double.tryParse(controller.text) ?? 0;
                  if (current > 0) {
                    setState(() {
                      controller.text = (current - 0.1).toStringAsFixed(1);
                    });
                  }
                },
                child: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  activity['description'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bedtime, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      "Sleep: ${activity['sleepHours']} hrs",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.monitor_weight, color: Colors.pinkAccent, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      "Weight: ${activity['weight']} kg",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "Workout: ${activity['workout']}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity['date'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteActivity(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Diary", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _showAddActivityDialog,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: _activities.isEmpty
          ? const Center(
              child: Text(
                "No activities yet. Tap '+' to add one!",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : AnimatedList(
              key: _listKey,
              initialItemCount: _activities.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index, animation) {
                return _buildActivityCard(_activities[index], animation, index);
              },
            ),
    );
  }
}
