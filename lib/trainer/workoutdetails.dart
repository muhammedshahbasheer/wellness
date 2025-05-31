import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserWorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserWorkoutDetailScreen({super.key, required this.user});

  @override
  State<UserWorkoutDetailScreen> createState() => _UserWorkoutDetailScreenState();
}

class _UserWorkoutDetailScreenState extends State<UserWorkoutDetailScreen> {
  double bmiValue = 0.0;
  List<FlSpot> weightSpots = [];
  List<FlSpot> sleepSpots = [];
  List<Map<String, dynamic>> diaryEntries = [];
  bool _showDiary = false;

  @override
  void initState() {
    super.initState();
    _fetchBMI();
    _fetchWeightHistory();
    _fetchSleepHistory();
    _fetchDiaryEntries();
  }

  Future<void> _fetchBMI() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user['uid'])
        .collection('bmi')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        bmiValue = snapshot.docs.first['bmi'];
      });
    }
  }

  Future<void> _fetchWeightHistory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user['uid'])
        .collection('bmi')
        .orderBy('timestamp')
        .get();

    List<FlSpot> spots = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      double weight = snapshot.docs[i]['weight'];
      spots.add(FlSpot(i.toDouble(), weight));
    }

    setState(() {
      weightSpots = spots;
    });
  }

  Future<void> _fetchSleepHistory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Diary')
        .doc(widget.user['uid'])
        .collection('Entries')
        .orderBy('timestamp')
        .get();

    List<FlSpot> spots = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      final data = snapshot.docs[i].data();
      double? sleepHour = double.tryParse(data['sleepHours'].toString());

      if (sleepHour != null && sleepHour > 0) {
        spots.add(FlSpot(i.toDouble(), sleepHour));
      }
    }

    setState(() {
      sleepSpots = spots;
    });
  }

  Future<void> _fetchDiaryEntries() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Diary')
        .doc(widget.user['uid'])
        .collection('Entries')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      diaryEntries = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.user['name'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('$name\'s Workout'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("BMI Indicator"),
            _bmiGauge(),
            const SizedBox(height: 20),
            _chartCard("Weight Progress", weightSpots, Colors.blue),
            const SizedBox(height: 20),
            _chartCard("Sleep Hours", sleepSpots, Colors.purple),
            const SizedBox(height: 20),
            _diarySectionToggle(),
            if (_showDiary)
              diaryEntries.isNotEmpty
                  ? Column(
                      children:
                          diaryEntries.map((entry) => _buildDiaryCard(entry)).toList(),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text("No Diary Entries",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _bmiGauge() {
    return SizedBox(
      height: 250,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 40,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue),
              GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green),
              GaugeRange(startValue: 25, endValue: 29.9, color: Colors.orange),
              GaugeRange(startValue: 30, endValue: 40, color: Colors.red),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(value: bmiValue),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  bmiValue.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chartCard(String title, List<FlSpot> spots, Color color) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: spots.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: color,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child:
                          Text("No Data", style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diarySectionToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDiary = !_showDiary;
        });
      },
      child: Row(
        children: [
          _sectionTitle("Diary Entries"),
          AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _showDiary ? 0.5 : 0,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(Map<String, dynamic> entry) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry['title'] ?? 'No Title',
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (entry['description'] != null)
              Text(entry['description'],
                  style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (entry['sleepHours'] != null)
                  Text("🛌 Sleep: ${entry['sleepHours']} hrs",
                      style: const TextStyle(color: Colors.white)),
                if (entry['weight'] != null)
                  Text("⚖️ Weight: ${entry['weight']} kg",
                      style: const TextStyle(color: Colors.white)),
                if (entry['workout'] != null)
                  Text("🏋️ Workout: ${entry['workout']}",
                      style: const TextStyle(color: Colors.white)),
              ],
            ),
            if (entry['date'] != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(entry['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
