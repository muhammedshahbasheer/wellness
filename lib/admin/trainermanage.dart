import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        title: Text('Trainer Management'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('trainers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No trainers found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var trainer = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(trainer['profileImageUrl']),
                  ),
                  title: Text(trainer['name'] ?? 'Unnamed Trainer'),
                  subtitle: Text(trainer['email'] ?? 'No email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => updateTrainerApproval(trainer.id, true),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
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
