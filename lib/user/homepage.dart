import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wellness/user/profilemanagment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;
    });
  }

  // List of pages
  List<Widget> get _pages => [
    const Center(child: Text('Dashboard', style: TextStyle(fontSize: 20, color: Colors.white))),
    const Center(child: Text('Diary', style: TextStyle(fontSize: 20, color: Colors.white))),
    const Center(child: Text('Add Entry', style: TextStyle(fontSize: 20, color: Colors.white))), // Placeholder for add button
    const Center(child: Text('Plans', style: TextStyle(fontSize: 20, color: Colors.white))),
    userId != null ? UserProfilePage(userId: userId!) : const Center(child: CircularProgressIndicator()), // Profile Page
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Prevent selection for the middle button
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.support_agent,
          color: Colors.blue,
          size: 50,
        ),
        onPressed: () {},
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Wellness', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Dynamic page switching
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tap
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bookOpen), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: Colors.blue), label: ''), // Non-selectable
          BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardList), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.userCircle), label: 'Profile'), // Navigate to Profile
        ],
      ),
    );
  }
}