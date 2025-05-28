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
  String height = '';
  String gender = '';
  bool isLoading = true;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedGender = 'Male';

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
          if (mounted) {
            setState(() {
              name = userDoc.get('name') ?? 'No name';
              email = userDoc.get('email') ?? 'No email';
              profileImageUrl = userDoc.get('profileImageUrl') ?? '';
              address = userDoc.get('address') ?? '';
              phoneNumber = userDoc.get('phoneNumber') ?? '';
              education = userDoc.get('education') ?? '';
              height = userDoc.get('height') ?? '';
              gender = userDoc.get('gender') ?? 'Male';
              isLoading = false;
            });

            _addressController.text = address;
            _phoneNumberController.text = phoneNumber;
            _educationController.text = education;
            _heightController.text = height;
            _selectedGender = gender;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateUserData() async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'education': _educationController.text.trim(),
          'height': _heightController.text.trim(),
          'gender': _selectedGender,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      } catch (e) {
        print('Error submitting feedback: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      }
    }
  }

  void _openFeedbackModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Submit Feedback",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type your feedback here...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                  cursorColor: Colors.deepPurple.shade400
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitFeedback(_feedbackController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      shadowColor: Colors.greenAccent.shade200,
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,color: Color.fromARGB(255, 176, 164, 164)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneNumberController.dispose();
    _educationController.dispose();
    _feedbackController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined),
            onPressed: _openFeedbackModal,
            tooltip: "Submit Feedback",
            splashRadius: 22,
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Colors.greenAccent,
              backgroundColor: Colors.grey[850],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
                    _buildProfileForm(),
                    const SizedBox(height: 35),
                    _buildActionTile(
                      Icons.logout,
                      "Logout",
                      () async {
                        await _auth.signOut();
                        if (mounted) Navigator.pop(context);
                      },
                      iconColor: Colors.redAccent.shade400,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.deepPurple.shade700,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[850],
              backgroundImage:
                  profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white70)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: TextStyle(
            color: Colors.deepPurple.shade400,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      color: Colors.grey[850],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(label: "Address", controller: _addressController),
            const SizedBox(height: 18),
            _buildTextField(label: "Phone Number", controller: _phoneNumberController, keyboardType: TextInputType.phone),
            const SizedBox(height: 18),
            _buildTextField(label: "Education", controller: _educationController),
            const SizedBox(height: 18),
            _buildTextField(label: "Height (in cm)", controller: _heightController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildGenderDropdown(),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _updateUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6,
                shadowColor: Colors.greenAccent.shade200,
              ),
              child: const Text(
                "Update Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Color.fromARGB(255, 203, 200, 200)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.greenAccent.shade400, width: 2),
        ),
      ),
      cursorColor: Colors.greenAccent.shade400,
    );
  }

  Widget _buildGenderDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          dropdownColor: Colors.grey[900],
          iconEnabledColor: Colors.deepPurple.shade400,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          onChanged: (String? newGender) {
            setState(() {
              _selectedGender = newGender!;
            });
          },
          items: <String>['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: 0.3,
          ),
        ),
        onTap: onTap,
        horizontalTitleGap: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        hoverColor: Colors.white.withOpacity(0.15),
      ),
    );
  }
}
