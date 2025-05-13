import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wellness/user/chatbot.dart';
import 'package:wellness/user/chatscreentrainer.dart';
import 'package:wellness/user/dashboard.dart';
import 'package:wellness/user/diary.dart';
import 'package:wellness/user/planandworkout.dart';
import 'package:wellness/user/plans.dart';
import 'package:wellness/user/profilemanagment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/user/reelview.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? userId;
  final PageController _pageController = PageController(); // Page controller for smooth navigation

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }
 void _onFabPressed() async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/start-rep-counter'),
    );
    if (response.statusCode == 200) {
      print("✅ Rep counter started!");
    } else {
      print("❌ Failed to start rep counter.");
    }
  } catch (e) {
    print("❌ Error connecting to rep counter API: $e");
  }
}

  // List of pages
  final List<Widget> _pages = [
     CalorieSliderScreen(),
    const DiaryPage(),
    const ReelViewer(), // Reel page (video won't autoplay when switching tabs)
    const PlansAndRecipesLauncher(),
    UserProfileScreen(), // Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });

    // Move to selected page smoothly
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.blue,
          size: 50,
        ),
        onPressed: () {
        _onFabPressed();
 

        },
      ),
      

      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tap
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bookOpen), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.video_collection, size: 40, color: Colors.blue), label: ''), // Middle button
          BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardList), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.userCircle), label: 'Profile'),
        ],
      ),
    );
  }
}
