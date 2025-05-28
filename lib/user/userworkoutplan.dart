import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserWorkoutPlanPage extends StatefulWidget {
  const UserWorkoutPlanPage({super.key});

  @override
  State<UserWorkoutPlanPage> createState() => _UserWorkoutPlanPageState();
}

class _UserWorkoutPlanPageState extends State<UserWorkoutPlanPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool isLoading = true;
  List<Map<String, dynamic>> workoutPlans = [];

  @override
  void initState() {
    super.initState();
    fetchWorkoutPlans();
  }

  Future<void> fetchWorkoutPlans() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dailyWorkoutPlans')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      workoutPlans = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
      isLoading = false;
    });
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Workout Plans'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : workoutPlans.isEmpty
              ? const Center(child: Text('No workout plans assigned.', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: workoutPlans.length,
                  itemBuilder: (context, index) {
                    final plan = workoutPlans[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${formatDate(plan['date'])}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Exercises: ${plan['exercises'].join(', ')}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text('Reps: ${plan['reps']}', style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('Calorie Goal: ${plan['calories']} kcal', style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('TDEE Type: ${plan['tdeeType']}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
