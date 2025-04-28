import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wellness/admin/trainerdetails.dart';
import 'trainerdetails.dart'; // <-- Import the detail page

class TrainerManagementPage extends StatefulWidget {
  const TrainerManagementPage({Key? key}) : super(key: key);

  @override
  State<TrainerManagementPage> createState() => _TrainerManagementPageState();
}

class _TrainerManagementPageState extends State<TrainerManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateTrainerApproval(String trainerId, bool isApproved) async {
    await _firestore.collection('trainers').doc(trainerId).update({'approved': isApproved});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isApproved ? 'Trainer approved' : 'Trainer rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Management'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('trainers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trainers found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var trainer = snapshot.data!.docs[index];
              var trainerData = trainer.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: trainerData['profileImageUrl'] != null
                        ? NetworkImage(trainerData['profileImageUrl'])
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  title: Text(trainerData['name'] ?? 'Unnamed Trainer'),
                  subtitle: Text(trainerData['email'] ?? 'No email'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainerDetailPage(
                          trainerId: trainer.id,
                          trainerData: trainerData,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => updateTrainerApproval(trainer.id, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => updateTrainerApproval(trainer.id, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
