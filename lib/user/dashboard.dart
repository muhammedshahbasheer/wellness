import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:wellness/user/chatbot.dart';
import 'package:wellness/user/chatscreentrainer.dart';
import 'package:wellness/user/caloriedetailscreen.dart';

class CalorieSliderScreen extends StatefulWidget {
  const CalorieSliderScreen({super.key});

  @override
  _CalorieSliderScreenState createState() => _CalorieSliderScreenState();
}

class _CalorieSliderScreenState extends State<CalorieSliderScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  double bmiValue = 0.0;
  double userHeight = 1.75;
  List<FlSpot> weightSpots = [];
  String dailyQuote = "Loading quote...";

  @override
  void initState() {
    super.initState();
    _fetchLatestBMI();
    _fetchWeightHistory();
    _generateMindFreshQuote();
  }

  Future<void> _fetchLatestBMI() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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

  void _showWeightInputDialog() {
    TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Today's Weight (kg)"),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 70.5"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              double weight = double.tryParse(weightController.text) ?? 0;
              if (weight <= 0) return;

              double bmi = weight / (userHeight * userHeight);
              setState(() {
                bmiValue = bmi;
              });

              await _saveBMI(weight, bmi);
              await _fetchWeightHistory();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBMI(double weight, double bmi) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bmi')
        .add({
      'weight': weight,
      'bmi': bmi,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _generateMindFreshQuote() async {
    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDK5rpV9edFjGgxvW4Iqulp7xG3Pew0lSU"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Give me a short and powerful motivational quote related to fitness, health, or working out. Keep it under 20 words."}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          dailyQuote = quote;
        });
      } else {
        print("API Error: ${response.body}");
        setState(() {
          dailyQuote = "Failed to load quote.";
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        dailyQuote = "Error fetching quote.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Wellness', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreenuser(userId: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
  onTap: _generateMindFreshQuote,
  child: Text(
    dailyQuote,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontStyle: FontStyle.italic,
      decoration: TextDecoration.underline,
    ),
  ),
),

              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _caloriePage(),
                  _weekReviewPage(),
                  _weightProgressPage(),
                  _sleepTrackerPage(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            chatWithAICard(),
            _bmiSection(),
          ],
        ),
      ),
    );
  }

 Widget _caloriePage() => Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Calorie Intake", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Track your daily calorie consumption.", style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalorieDetailScreen()),
            );
          },
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
          child: const Text("View Details"),
        ),
      ],
    ),
  ),
);

  Widget _weekReviewPage() => _dashboardCard(
        title: "Week Review",
        subtitle: "Analyze your weekly health trends.",
        buttonText: "Check Insights",
      );

  Widget _weightProgressPage() => _chartCard("Weight Progress", Colors.blue);

  Widget _sleepTrackerPage() => _chartCard("Sleep Hours", Colors.purple);

  Widget _bmiSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "BMI Indicator",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _showWeightInputDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: BMIIndicator(bmi: bmiValue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: title == "Weight Progress"
                    ? LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: weightSpots,
                              isCurved: true,
                              color: color,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      )
                    : const Center(child: Text("No Data", style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({required String title, required String subtitle, required String buttonText}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatWithAICard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.smart_toy_outlined, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Chat with AI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Ask anything about health, fitness, or diet.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BMIIndicator extends StatelessWidget {
  final double bmi;

  const BMIIndicator({Key? key, required this.bmi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 40,
            ranges: <GaugeRange>[
              GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue),
              GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green),
              GaugeRange(startValue: 25, endValue: 29.9, color: Colors.yellow),
              GaugeRange(startValue: 30, endValue: 40, color: Colors.red),
            ],
            pointers: <GaugePointer>[NeedlePointer(value: bmi)],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(positionFactor: 0.5, widget: Text(bmi.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        ],
      ),
    );
  }
}
