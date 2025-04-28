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
  bool isUserAssignedToAnotherTrainer = false; // Flag to track if user is already assigned to another trainer

  @override
  void initState() {
    super.initState();
    trainerId = widget.trainerId;
    trainerData = widget.trainerData;
    _fetchAssignedUsers();
    _fetchAllUsers();
  }

  // Fetch the assigned users for this trainer
  Future<void> _fetchAssignedUsers() async {
    try {
      DocumentSnapshot trainerDoc = await FirebaseFirestore.instance.collection('trainers').doc(trainerId).get();
      if (trainerDoc.exists) {
        setState(() {
          assignedUsers = List<String>.from(trainerDoc.get('assignedUsers') ?? []);
        });
      }
    } catch (e) {
      print('Error fetching assigned users: $e');
    }
  }

  // Fetch all users to display for assignment
  Future<void> _fetchAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = usersSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Check if the user is already assigned to another trainer
  Future<bool> _isUserAssignedToAnotherTrainer(String userId) async {
    try {
      // Query all trainers to check if the user is already assigned to any trainer
      QuerySnapshot trainersSnapshot = await FirebaseFirestore.instance.collection('trainers').get();
      for (var doc in trainersSnapshot.docs) {
        List<dynamic> assignedUsersList = List.from(doc.get('assignedUsers') ?? []);
        if (assignedUsersList.contains(userId)) {
          return true; // If found, the user is already assigned
        }
      }
      return false; // User is not assigned to any trainer
    } catch (e) {
      print('Error checking if user is assigned: $e');
      return false;
    }
  }

  // Assign a user to the trainer
  Future<void> _assignUserToTrainer(String userId) async {
    // Check if the user is already assigned to another trainer
    bool isAssigned = await _isUserAssignedToAnotherTrainer(userId);
    if (isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is already assigned to another trainer')));
      return;
    }

    try {
      // Assign the user to this trainer
      await FirebaseFirestore.instance.collection('trainers').doc(trainerId).update({
        'assignedUsers': FieldValue.arrayUnion([userId]),
      });
      setState(() {
        assignedUsers.add(userId); // Add user to assigned list
      });
      print('User assigned to trainer');
    } catch (e) {
      print('Error assigning user to trainer: $e');
    }
  }

  // Unassign a user from this trainer
  Future<void> _unassignUserFromTrainer(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('trainers').doc(trainerId).update({
        'assignedUsers': FieldValue.arrayRemove([userId]),
      });
      setState(() {
        assignedUsers.remove(userId); // Remove user from assigned list
      });
      print('User unassigned from trainer');
    } catch (e) {
      print('Error unassigning user from trainer: $e');
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
                      return ListTile(
                        title: Text(userId),
                        trailing: ElevatedButton(
                          onPressed: () => _unassignUserFromTrainer(userId),
                          child: const Text('Unassign'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                      bool isAssigned = assignedUsers.contains(user['uid']);
                      return ListTile(
                        title: Text(user['name'] ?? 'No name'),
                        subtitle: Text(user['email'] ?? 'No email'),
                        trailing: isAssigned
                            ? const Text('Assigned', style: TextStyle(color: Colors.green))
                            : ElevatedButton(
                                onPressed: () {
                                  _isUserAssignedToAnotherTrainer(user['uid']).then((isAssignedToAnother) {
                                    if (!isAssignedToAnother) {
                                      _assignUserToTrainer(user['uid']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('User is already assigned to another trainer')));
                                    }
                                  });
                                },
                                child: const Text('Assign'),
                              ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
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
