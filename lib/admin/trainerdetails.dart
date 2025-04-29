import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerDetailPage extends StatefulWidget {
  final String trainerId;
  final Map<String, dynamic> trainerData;

  const TrainerDetailPage({Key? key, required this.trainerId, required this.trainerData}) : super(key: key);

  @override
  _TrainerDetailPageState createState() => _TrainerDetailPageState();
}

class _TrainerDetailPageState extends State<TrainerDetailPage> {
  late String trainerId;
  late Map<String, dynamic> trainerData;
  List<Map<String, dynamic>> users = [];
  List<String> assignedUsers = [];

  @override
  void initState() {
    super.initState();
    trainerId = widget.trainerId;
    trainerData = widget.trainerData;
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await _fetchAssignedUsers();
    await _fetchAllUsers();
  }

  // Fetch the assigned users for this trainer
  Future<void> _fetchAssignedUsers() async {
    try {
      DocumentSnapshot trainerDoc = await FirebaseFirestore.instance.collection('trainers').doc(trainerId).get();
      if (trainerDoc.exists) {
        assignedUsers = List<String>.from(trainerDoc.get('assignedUsers') ?? []);
      }
    } catch (e) {
      print('Error fetching assigned users: $e');
    }
  }

  // Fetch all users
  Future<void> _fetchAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      users = usersSnapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        userData['uid'] = doc.id;
        return userData;
      }).toList();
      setState(() {}); // Refresh the UI
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Check if a user is assigned to any trainer
  Future<bool> _isUserAssignedToAnyTrainer(String userId) async {
    try {
      QuerySnapshot trainersSnapshot = await FirebaseFirestore.instance.collection('trainers').get();
      for (var doc in trainersSnapshot.docs) {
        List<dynamic> assignedUsersList = List.from(doc.get('assignedUsers') ?? []);
        if (assignedUsersList.contains(userId)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking if user is assigned: $e');
      return false;
    }
  }

  // Assign user to trainer
  Future<void> _assignUserToTrainer(String userId) async {
    bool isAssigned = await _isUserAssignedToAnyTrainer(userId);
    if (isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is already assigned to another trainer')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('trainers').doc(trainerId).update({
        'assignedUsers': FieldValue.arrayUnion([userId]),
      });
      await _fetchAllData(); // Refresh everything
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User assigned successfully')));
    } catch (e) {
      print('Error assigning user: $e');
    }
  }

  // Unassign user from trainer
  Future<void> _unassignUserFromTrainer(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('trainers').doc(trainerId).update({
        'assignedUsers': FieldValue.arrayRemove([userId]),
      });
      await _fetchAllData(); // Refresh everything
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User unassigned successfully')));
    } catch (e) {
      print('Error unassigning user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Details'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: trainerData['profileImageUrl'] != null
                    ? NetworkImage(trainerData['profileImageUrl'])
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                trainerData['name'] ?? 'No name',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                trainerData['email'] ?? 'No email',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(label: 'Phone', value: trainerData['phone'] ?? 'Not available'),
                    const SizedBox(height: 10),
                    DetailRow(label: 'Specialization', value: trainerData['specialization'] ?? 'Not available'),
                    const SizedBox(height: 10),
                    DetailRow(label: 'Experience', value: trainerData['experience']?.toString() ?? 'Not available'),
                    const SizedBox(height: 20),
                    const Text(
                      'Assigned Users:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (assignedUsers.isEmpty)
                      const Text('No users assigned.')
                    else
                      ...assignedUsers.map((userId) {
  final user = users.firstWhere(
    (u) => u['uid'] == userId,
    orElse: () => {'name': 'Unknown', 'email': 'Not found'},
  );
  return ListTile(
    title: Text(user['name'] ?? 'Unknown'),
    subtitle: Text(user['email'] ?? 'Not found'),
    trailing: ElevatedButton(
      onPressed: () => _unassignUserFromTrainer(userId),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Unassign'),
    ),
  );
}).toList(),

                    const SizedBox(height: 20),
                    const Text(
                      'All Users:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (users.isEmpty)
                      const Text('No users available.')
                    else
                      ...users.map((user) {
                        return FutureBuilder<bool>(
                          future: _isUserAssignedToAnyTrainer(user['uid']),
                          builder: (context, snapshot) {
                            bool isAssigned = snapshot.data ?? false;
                            return ListTile(
                              title: Text(user['name'] ?? 'No name'),
                              subtitle: Text(user['email'] ?? 'No email'),
                              trailing: isAssigned
                                  ? const Text('Assigned', style: TextStyle(color: Colors.green))
                                  : ElevatedButton(
                                      onPressed: () => _assignUserToTrainer(user['uid']),
                                      child: const Text('Assign'),
                                    ),
                            );
                          },
                        );
                      }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
