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
  String profileImageUrl = ''; 
  String address = '';
  String phoneNumber = '';
  String education = '';
  String feedbackMessage = '';
  bool isLoading = true;

  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc.get('name') ?? 'No name';
            email = userDoc.get('email') ?? 'No email';
            profileImageUrl = userDoc.get('profileImageUrl') ?? ''; 
            address = userDoc.get('address') ?? '';
            phoneNumber = userDoc.get('phoneNumber') ?? '';
            education = userDoc.get('education') ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'address': address,
          'phoneNumber': phoneNumber,
          'education': education,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      } catch (e) {
        print('Error updating user data: $e');
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (user != null && feedbackMessage.isNotEmpty) {
      try {
        await _firestore.collection('feedback').add({
          'userId': user!.uid,
          'feedback': feedbackMessage,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _feedbackController.clear();
        setState(() {
          feedbackMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted successfully')));
      } catch (e) {
        print('Error submitting feedback: $e');
      }
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
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileForm(),
                  const SizedBox(height: 20),
                  _buildFeedbackForm(),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl.isEmpty
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          email,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Address',
              initialValue: address,
              onChanged: (value) {
                setState(() {
                  address = value;
                });
              },
            ),
            _buildTextField(
              label: 'Phone Number',
              initialValue: phoneNumber,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
            ),
            _buildTextField(
              label: 'Education',
              initialValue: education,
              onChanged: (value) {
                setState(() {
                  education = value;
                });
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Feedback',
              initialValue: feedbackMessage,
              onChanged: (value) {
                setState(() {
                  feedbackMessage = value;
                });
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {Color iconColor = Colors.black}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}
