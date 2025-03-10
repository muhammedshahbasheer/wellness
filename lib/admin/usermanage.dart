import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profileImageUrl'] != null
                        ? NetworkImage(user['profileImageUrl'])
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  title: Text(user['name'] ?? 'No name'),
                  subtitle: Text(user['email'] ?? 'No email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('users').doc(users[index].id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
                    },
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
