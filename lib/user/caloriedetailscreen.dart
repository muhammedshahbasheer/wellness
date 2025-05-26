import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalorieDetailScreen extends StatefulWidget {
  const CalorieDetailScreen({super.key});

  @override
  State<CalorieDetailScreen> createState() => _CalorieDetailScreenState();
}

class _CalorieDetailScreenState extends State<CalorieDetailScreen> {
  String gender = 'male';
  double height = 170; // in cm
  double weight = 65; // in kg
  int age = 25; // default age
  double bmr = 0;
  double tdee = 0;
  String activityLevel = 'Lightly active';

  Map<String, int> mealCalories = {
    'Breakfast': 0,
    'Lunch': 0,
    'Dinner': 0,
    'Snacks': 0,
  };

  final List<String> activityLevels = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extra active',
  ];

  final TextEditingController calorieController = TextEditingController();
  String selectedMeal = 'Breakfast';

  // --- Added for midnight refresh ---
  DateTime _lastCheckedDay = DateTime.now();
  late Timer _midnightTimer;
  StreamSubscription? _calorieSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToCalorieIntake();
    _startMidnightWatcher();
  }

  void _startMidnightWatcher() {
    _midnightTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _lastCheckedDay.day) {
        _lastCheckedDay = now;

        setState(() {
          mealCalories = {
            'Breakfast': 0,
            'Lunch': 0,
            'Dinner': 0,
            'Snacks': 0,
          };
        });

        _calorieSubscription?.cancel();
        _listenToCalorieIntake();
      }
    });
  }

  void _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          height = double.tryParse(data['height'].toString()) ?? 170;
          weight = double.tryParse(data['weight'].toString()) ?? 65;
          gender = (data['gender'] ?? 'male').toLowerCase();
          age = int.tryParse(data['age'].toString()) ?? 25; // load age if exists
          _calculateCalories();
        });
      }
    }
  }

  void _calculateCalories() {
    if (gender == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    switch (activityLevel) {
      case 'Sedentary':
        tdee = bmr * 1.2;
        break;
      case 'Lightly active':
        tdee = bmr * 1.375;
        break;
      case 'Moderately active':
        tdee = bmr * 1.55;
        break;
      case 'Very active':
        tdee = bmr * 1.725;
        break;
      case 'Extra active':
        tdee = bmr * 1.9;
        break;
      default:
        tdee = bmr * 1.2;
    }
  }

  void _listenToCalorieIntake() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _calorieSubscription = FirebaseFirestore.instance
        .collection('calorieIntake')
        .doc(uid)
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .listen((snapshot) {
      final updatedCalories = {
        'Breakfast': 0,
        'Lunch': 0,
        'Dinner': 0,
        'Snacks': 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final meal = data['mealType'] ?? 'Other';
        final cals = int.tryParse(data['calories'].toString()) ?? 0;

        if (updatedCalories.containsKey(meal)) {
          updatedCalories[meal] = updatedCalories[meal]! + cals;
        }
      }

      setState(() {
        mealCalories = updatedCalories;
      });
    });
  }

  void _addCalorieEntry() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final int? calories = int.tryParse(calorieController.text);
    if (calories == null || selectedMeal.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('calorieIntake')
        .doc(uid)
        .collection('entries')
        .add({
      'mealType': selectedMeal,
      'calories': calories,
      'timestamp': Timestamp.now(),
    });

    calorieController.clear();
    setState(() {
      selectedMeal = 'Breakfast';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $calories kcal to $selectedMeal')),
    );
  }

  int get totalIntake {
    return mealCalories.values.fold(0, (sum, item) => sum + item);
  }

  @override
  void dispose() {
    _midnightTimer.cancel();
    _calorieSubscription?.cancel();
    calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Calorie Tracker", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Calorie Intake",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "• Breakfast: ${mealCalories['Breakfast']} kcal\n"
                    "• Lunch: ${mealCalories['Lunch']} kcal\n"
                    "• Dinner: ${mealCalories['Dinner']} kcal\n"
                    "• Snacks: ${mealCalories['Snacks']} kcal",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text("Total Intake: $totalIntake kcal",
                      style: const TextStyle(
                          color: Colors.lightBlueAccent, fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text("Goal: 2000 kcal",
                      style:
                          TextStyle(color: Colors.greenAccent, fontSize: 16)),
                  const SizedBox(height: 30),
                  const Text("Activity Level:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: activityLevel,
                    dropdownColor: Colors.grey[900],
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: activityLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        activityLevel = newValue!;
                        _calculateCalories();
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Text("Calories Needed to Burn: ${tdee.toStringAsFixed(0)} kcal",
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 16)),
                  const SizedBox(height: 30),
                  const Text("Tip:",
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const Text("Stay hydrated and avoid late-night snacking!",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 30),
                  const Text("Add Calorie Entry:",
                      style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedMeal,
                    dropdownColor: Colors.grey[900],
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Meal Type',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                        .map((String meal) {
                      return DropdownMenuItem<String>(
                        value: meal,
                        child: Text(meal),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMeal = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addCalorieEntry,
                    child: const Text("Add Entry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
