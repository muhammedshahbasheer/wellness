import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignedUsersScreen extends StatefulWidget {
  const AssignedUsersScreen({super.key});

  @override
  State<AssignedUsersScreen> createState() => _AssignedUsersScreenState();
}

class _AssignedUsersScreenState extends State<AssignedUsersScreen> {
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
      // Fetch trainer document
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

      // Check if the assignedUsers field exists and is a list
      final List<dynamic> userIds = trainerDoc.data()?['assignedUsers'] ?? [];

      print('Assigned User IDs: $userIds'); // Log user IDs for debugging

      // Handle case where no users are assigned
      if (userIds.isEmpty) {
        print('No users assigned.');
        setState(() {
          assignedUsers = [];
          isLoading = false;
        });
        return;
      }

      // Split the list if there are more than 10 IDs to avoid Firestore's 'whereIn' limitation
      List<QuerySnapshot> userSnapshots = [];
      const int maxBatchSize = 10;
      for (int i = 0; i < userIds.length; i += maxBatchSize) {
        final userIdsBatch = userIds.sublist(i, (i + maxBatchSize) < userIds.length ? (i + maxBatchSize) : userIds.length);
        final batchSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIdsBatch)
            .get();
        userSnapshots.add(batchSnapshot);
      }

      // Combine all snapshots
      List<Map<String, dynamic>> users = [];
      for (var snapshot in userSnapshots) {
        for (var doc in snapshot.docs) {
          users.add(doc.data() as Map<String, dynamic>);
        }
      }

      // Log the users data to debug
      print('Fetched Users: $users');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Assigned Users'),
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
                      ),
                    );
                  },
                ),
    );
  }
}
