import 'package:flutter/material.dart';
import 'package:wellness/trainer/clients.dart';
import 'package:wellness/trainer/profile.dart';
import 'package:wellness/trainer/reel.dart';
import 'package:wellness/trainer/schedule.dart';
import 'package:wellness/trainer/workout.dart';
import 'package:wellness/trainer/messages.dart';
import 'package:wellness/trainer/workoutplan.dart'; // Assuming this is the correct import
 // Your trainer profile screen

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AssignWorkoutPlanPage(),
    AssignedUsersScreen(),
    //SchedulePage(),
    AssignedMessagesScreen(),
    TrainerProfileScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Floating action button for uploading reels
  Widget _buildReelButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadReelPage()));
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: _buildReelButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Clients'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
