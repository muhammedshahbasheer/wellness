import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late DocumentSnapshot userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc;
          isLoading = false;
        });
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('No user data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userData['profileImageUrl']), // Cloudinary URL
                        onBackgroundImageError: (error, stackTrace) => const Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 16),
                      Text(userData['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(userData['email'], style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
    );
  }
}

// Usage example:
// Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: 'someUserId')));
