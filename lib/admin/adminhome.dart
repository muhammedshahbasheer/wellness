import 'package:flutter/material.dart';
import 'package:wellness/admin/usermanage.dart';
import 'package:wellness/admin/trainermanage.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Manage Users', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainerManagementPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Manage Trainers', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}