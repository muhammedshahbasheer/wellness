import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/trainer/workoutdetails.dart';

// ✅ Renamed class
class WorkoutProgressScreen extends StatefulWidget {
  const WorkoutProgressScreen({super.key});

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  List<Map<String, dynamic>> assignedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedUsers();
  }

  Future<void> loadAssignedUsers() async {
    final String trainerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      final trainerDoc = await FirebaseFirestore.instance
          .collection('trainers')
          .doc(trainerId)
          .get();

      if (!trainerDoc.exists) {
        print('Trainer document not found!');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final List<dynamic> userIds = trainerDoc.data()?['assignedUsers'] ?? [];

      if (userIds.isEmpty) {
        print('No users assigned.');
        setState(() {
          assignedUsers = [];
          isLoading = false;
        });
        return;
      }

      List<QuerySnapshot> userSnapshots = [];
      const int maxBatchSize = 10;
      for (int i = 0; i < userIds.length; i += maxBatchSize) {
        final userIdsBatch = userIds.sublist(
            i, (i + maxBatchSize) < userIds.length ? (i + maxBatchSize) : userIds.length);
        final batchSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIdsBatch)
            .get();
        userSnapshots.add(batchSnapshot);
      }

      List<Map<String, dynamic>> users = [];
      for (var snapshot in userSnapshots) {
        for (var doc in snapshot.docs) {
          final userData = doc.data() as Map<String, dynamic>;
          userData['id'] = doc.id; // ✅ Store user ID
          users.add(userData);
        }
      }

      setState(() {
        assignedUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading assigned users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToUserDetail(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserWorkoutDetailScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Workout Progress'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : assignedUsers.isEmpty
              ? const Center(
                  child: Text('No users assigned.', style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  itemCount: assignedUsers.length,
                  itemBuilder: (context, index) {
                    final user = assignedUsers[index];
                    return Card(
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text(
                          user['name'] ?? 'Unnamed',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          user['email'] ?? '',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        onTap: () => navigateToUserDetail(user), // ✅ Tap action
                      ),
                    );
                  },
                ),
    );
  }
}
