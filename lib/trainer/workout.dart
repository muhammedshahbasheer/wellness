import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wellness/trainer/messages.dart';
class AssignedMessagesScreen extends StatefulWidget {
  const AssignedMessagesScreen({Key? key}) : super(key: key);

  @override
  State<AssignedMessagesScreen> createState() => _AssignedMessagesScreenState();
}

class _AssignedMessagesScreenState extends State<AssignedMessagesScreen> {
  final String trainerId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool isLoading = true;
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    fetchAssignedUsersWithUnreadCount();
  }

  Future<void> fetchAssignedUsersWithUnreadCount() async {
    try {
      final trainerDoc = await FirebaseFirestore.instance.collection('trainers').doc(trainerId).get();
      final List<dynamic> assignedUserIds = trainerDoc.data()?['assignedUsers'] ?? [];

      if (assignedUserIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: assignedUserIds)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in usersSnapshot.docs) {
        String userId = doc.id;

        final unreadSnapshot = await FirebaseFirestore.instance
            .collection('Messages')
            .where('senderId', isEqualTo: userId)
            .where('receiverId', isEqualTo: trainerId)
            .where('isRead', isEqualTo: false)
            .get();

        results.add({
          'userId': userId,
          'name': doc['name'] ?? 'No Name',
          'email': doc['email'] ?? '',
          'unreadCount': unreadSnapshot.size,
        });
      }

      setState(() {
        userData = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void openChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreentrainer(userId: userId, userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('User Messages'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : userData.isEmpty
              ? const Center(child: Text('No assigned users.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    final user = userData[index];
                    return ListTile(
                      onTap: () => openChat(user['userId'], user['name']),
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(user['name'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(user['email'], style: const TextStyle(color: Colors.white60)),
                      trailing: user['unreadCount'] > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${user['unreadCount']}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
    );
  }
}


