import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignWorkoutPlanPage extends StatefulWidget {
  const AssignWorkoutPlanPage({super.key});

  @override
  State<AssignWorkoutPlanPage> createState() => _AssignWorkoutPlanPageState();
}

class _AssignWorkoutPlanPageState extends State<AssignWorkoutPlanPage> {
  String? selectedUserId;
  List<Map<String, dynamic>> assignedUsers = [];
  List<String> exerciseList = [];
  final TextEditingController repsController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController breakfastController = TextEditingController();
  final TextEditingController noonController = TextEditingController();
  final TextEditingController supperController = TextEditingController();
  final TextEditingController dinnerController = TextEditingController();
  final TextEditingController supplementsController = TextEditingController();
  String? selectedTdeeType;

  final List<String> availableExercises = [
    'Push-ups', 'Squats', 'Plank', 'Jumping Jacks', 'Sit-ups', 'Lunges'
  ];

  final List<String> tdeeTypes = [
    'Sedentary', 'Lightly Active', 'Active', 'Very Active'
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedUsers();
  }

  Future<void> fetchAssignedUsers() async {
    final trainerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final trainerDoc =
        await FirebaseFirestore.instance.collection('trainers').doc(trainerId).get();

    if (!trainerDoc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final List<dynamic> userIds = trainerDoc.data()?['assignedUsers'] ?? [];
    List<Map<String, dynamic>> users = [];

    for (var i = 0; i < userIds.length; i += 10) {
      var batch = userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10);
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      users.addAll(snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}));
    }

    setState(() {
      assignedUsers = users;
      isLoading = false;
    });
  }

  Future<void> assignWorkoutPlan() async {
    if (selectedUserId == null ||
        exerciseList.isEmpty ||
        repsController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        selectedTdeeType == null ||
        breakfastController.text.isEmpty ||
        noonController.text.isEmpty ||
        supperController.text.isEmpty ||
        dinnerController.text.isEmpty ||
        supplementsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserId)
        .collection('dailyWorkoutPlans')
        .add({
      'exercises': exerciseList,
      'reps': repsController.text,
      'calories': caloriesController.text,
      'tdeeType': selectedTdeeType,
      'dietPlan': {
        'breakfast': breakfastController.text,
        'noon': noonController.text,
        'supper': supperController.text,
        'dinner': dinnerController.text,
        'supplements': supplementsController.text,
      },
      'date': DateTime.now(),
      'trainerId': FirebaseAuth.instance.currentUser!.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout Plan Assigned')),
    );

    setState(() {
      selectedUserId = null;
      exerciseList.clear();
      repsController.clear();
      caloriesController.clear();
      breakfastController.clear();
      noonController.clear();
      supperController.clear();
      dinnerController.clear();
      supplementsController.clear();
      selectedTdeeType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Assign Workout Plan'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      dropdownColor: Colors.grey[900],
                      decoration: const InputDecoration(
                        labelText: 'Select User',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      items: assignedUsers
                          .map<DropdownMenuItem<String>>((user) => DropdownMenuItem<String>(
                                value: user['id'],
                                child: Text(
                                  user['name'] ?? user['email'] ?? 'Unnamed',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedUserId = value),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Exercises',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: availableExercises.map((exercise) {
                        final isSelected = exerciseList.contains(exercise);
                        return ChoiceChip(
                          label: Text(exercise),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              isSelected
                                  ? exerciseList.remove(exercise)
                                  : exerciseList.add(exercise);
                            });
                          },
                          selectedColor: Colors.green,
                          backgroundColor: Colors.grey[800],
                          labelStyle: const TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: repsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: caloriesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Calorie Goal',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedTdeeType,
                      dropdownColor: Colors.grey[900],
                      decoration: const InputDecoration(
                        labelText: 'TDEE Type',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      items: tdeeTypes
                          .map<DropdownMenuItem<String>>((tdee) => DropdownMenuItem<String>(
                                value: tdee,
                                child: Text(
                                  tdee,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedTdeeType = value),
                    ),
                    const SizedBox(height: 20),
                    const Text('Diet Plan', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: breakfastController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Breakfast',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noonController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Noon',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: supperController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Supper',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dinnerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Dinner',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: supplementsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Supplements',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Send Plan'),
                      onPressed: assignWorkoutPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
