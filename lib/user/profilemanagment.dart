import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String name = '';
  String email = '';
  String profileImageUrl = ''; // Correct field name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (user != null) {
        print('User ID: ${user!.uid}'); // Debug user ID

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();

        if (userDoc.exists) {
          print('User document data: ${userDoc.data()}'); // Debug full document

          setState(() {
            name = userDoc.get('name') ?? 'No name';
            email = userDoc.get('email') ?? 'No email';
            profileImageUrl = userDoc.get('profileImageUrl') ?? ''; // Fixed field name
            isLoading = false;
          });
        } else {
          print('No user document found for ID: ${user!.uid}');
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionTile(Icons.logout, "Logout", () async {
                    await _auth.signOut();
                    Navigator.pop(context);
                  }, iconColor: Colors.red),
                ],
              ),
            ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {Color iconColor = Colors.black}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}
