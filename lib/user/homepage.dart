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

  // List of pages
  final List<Widget> _pages = [
    const CalorieSliderScreen(),
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
          Navigator.push(context,
          MaterialPageRoute(builder : (context) => ChatScreen()));
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
