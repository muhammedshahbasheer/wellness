import 'package:flutter/material.dart';
import 'package:wellness/trainer/reel.dart';



class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(context, Icons.fitness_center, 'Workouts', Colors.blue),
            _buildDashboardCard(context, Icons.person, 'Clients', Colors.green),
            _buildDashboardCard(context, Icons.schedule, 'Schedule', Colors.orange),
            _buildDashboardCard(context, Icons.chat, 'Messages', Colors.purple),
            _buildDashboardCard(context, Icons.video_library, 'Reels', Colors.red, isReels: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, IconData icon, String title, Color color, {bool isReels = false}) {
    return GestureDetector(
      onTap: () {
        if (isReels) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadReelPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title clicked!')),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
