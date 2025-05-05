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
  bool isLoading = true;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

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

          _addressController.text = address;
          _phoneNumberController.text = phoneNumber;
          _educationController.text = education;
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'education': _educationController.text.trim(),
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      } catch (e) {
        print('Error updating user data: $e');
      }
    }
  }

  Future<void> _submitFeedback(String feedbackMessage) async {
    if (user != null && feedbackMessage.isNotEmpty) {
      try {
        await _firestore.collection('feedback').add({
          'userId': user!.uid,
          'feedback': feedbackMessage,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context);
        _feedbackController.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Feedback submitted successfully')));
      } catch (e) {
        print('Error submitting feedback: $e');
      }
    }
  }

  void _openFeedbackModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Submit Feedback",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type your feedback...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _submitFeedback(_feedbackController.text),
                child: const Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined),
            onPressed: _openFeedbackModal,
            tooltip: "Submit Feedback",
          )
        ],
        automaticallyImplyLeading: false
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 25),
                  _buildProfileForm(),
                  const SizedBox(height: 30),
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
          backgroundColor: Colors.white10,
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
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(label: "Address", controller: _addressController),
            const SizedBox(height: 15),
            _buildTextField(label: "Phone Number", controller: _phoneNumberController),
            const SizedBox(height: 15),
            _buildTextField(label: "Education", controller: _educationController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text("Update Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      ),
    );
  }
}
