import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainerId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('trainers').doc(trainerId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || !snapshot.data!.exists)
          return const Center(child: Text('Profile not found', style: TextStyle(color: Colors.white)));

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundImage: data['profileImageUrl'] != null && data['profileImageUrl'] != ""
                    ? NetworkImage(data['profileImageUrl'])
                    : null,
                child: (data['profileImageUrl'] == null || data['profileImageUrl'] == "")
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(height: 20),
              Text(
                data['name'] ?? 'No name',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                data['email'] ?? 'No email',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                data['phone'] ?? 'No phone number',
                style: const TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Logout"),
              )
            ],
          ),
        );
      },
    );
  }
}
